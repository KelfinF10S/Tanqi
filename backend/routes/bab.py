# routes/bab.py

from flask import Blueprint, jsonify, request
from flask_jwt_extended import jwt_required, get_jwt_identity
from extensions import db
from models.models import (
    Bab, Topik, Materi, UserBab, UserMateri,
    Kuis, SoalKuis, UserKuis, UserJawabanKuis
)

bab_bp = Blueprint("bab", __name__)


# ──────────────────────────────────────────────
# GET /api/bab
# ──────────────────────────────────────────────
@bab_bp.route("/", methods=["GET"])
@jwt_required()
def get_all_bab():
    user_id  = int(get_jwt_identity())
    bab_list = Bab.query.order_by(Bab.id).all()

    result = []
    for b in bab_list:
        user_bab = UserBab.query.filter_by(userid=user_id, babid=b.id).first()

        if not user_bab:
            user_bab = UserBab(
                userid=user_id,
                babid=b.id,
                locked=(b.id != 1)
            )
            db.session.add(user_bab)
            db.session.commit()

        kuis = Kuis.query.filter_by(babid=b.id).first()
        user_kuis = None
        if kuis:
            user_kuis = UserKuis.query.filter_by(
                userid=user_id, kuisid=kuis.id
            ).first()

        bab_data                  = b.to_dict()
        bab_data["locked"]        = user_bab.locked
        bab_data["is_completed"]  = user_kuis.is_completed if user_kuis else False
        bab_data["nilai"]         = user_kuis.nilai if user_kuis else 0
        result.append(bab_data)

    return jsonify({"total": len(result), "data": result}), 200


# ──────────────────────────────────────────────
# GET /api/bab/<id>/materi
# ──────────────────────────────────────────────
@bab_bp.route("/<int:bab_id>/materi", methods=["GET"])
@jwt_required()
def get_materi_by_bab(bab_id):
    user_id = int(get_jwt_identity())

    bab      = Bab.query.get_or_404(bab_id)
    user_bab = UserBab.query.filter_by(userid=user_id, babid=bab_id).first()

    if not user_bab or user_bab.locked:
        return jsonify({"message": "Bab ini masih terkunci"}), 403

    materi_list = Materi.query.filter_by(babid=bab_id).order_by(Materi.urutan).all()

    result = []
    for m in materi_list:
        user_materi = UserMateri.query.filter_by(
            userid=user_id, materiid=m.id
        ).first()

        materi_data                 = m.to_dict()
        materi_data["is_completed"] = user_materi.is_completed if user_materi else False
        result.append(materi_data)

    kuis = Kuis.query.filter_by(babid=bab_id).first()
    user_kuis = UserKuis.query.filter_by(
        userid=user_id, kuisid=kuis.id
    ).first() if kuis else None

    bab_data                 = bab.to_dict()
    bab_data["locked"]       = user_bab.locked
    bab_data["is_completed"] = user_kuis.is_completed if user_kuis else False
    bab_data["nilai"]        = user_kuis.nilai if user_kuis else 0

    return jsonify({
        "bab":    bab_data,
        "total":  len(result),
        "materi": result
    }), 200


# ──────────────────────────────────────────────
# POST /api/bab/materi/<id>/selesai
# Tandai materi sudah dibaca/dipelajari
# ──────────────────────────────────────────────
@bab_bp.route("/materi/<int:materi_id>/selesai", methods=["POST"])
@jwt_required()
def selesaikan_materi(materi_id):
    user_id = int(get_jwt_identity())

    materi = Materi.query.get_or_404(materi_id)

    user_bab = UserBab.query.filter_by(
        userid=user_id, babid=materi.babid
    ).first()

    if not user_bab or user_bab.locked:
        return jsonify({"message": "Bab ini masih terkunci"}), 403

    user_materi = UserMateri.query.filter_by(
        userid=user_id, materiid=materi_id
    ).first()

    if not user_materi:
        user_materi = UserMateri(
            userid=user_id,
            materiid=materi_id,
            is_completed=True
        )
        db.session.add(user_materi)
    else:
        user_materi.is_completed = True

    db.session.commit()

    return jsonify({
        "message": "Materi ditandai selesai",
        "data": user_materi.to_dict()
    }), 200


# ──────────────────────────────────────────────
# GET /api/bab/<id>/kuis
# Ambil soal aktif (berurutan) untuk dikerjakan
# ──────────────────────────────────────────────
@bab_bp.route("/<int:bab_id>/kuis", methods=["GET"])
@jwt_required()
def get_kuis_by_bab(bab_id):
    user_id = int(get_jwt_identity())

    bab      = Bab.query.get_or_404(bab_id)
    user_bab = UserBab.query.filter_by(userid=user_id, babid=bab_id).first()

    if not user_bab or user_bab.locked:
        return jsonify({"message": "Bab ini masih terkunci"}), 403

    kuis = Kuis.query.filter_by(babid=bab_id).first_or_404()

    user_kuis = UserKuis.query.filter_by(
        userid=user_id, kuisid=kuis.id
    ).first()

    if not user_kuis:
        user_kuis = UserKuis(userid=user_id, kuisid=kuis.id, attempt=1)
        db.session.add(user_kuis)
        db.session.commit()

    soal_list = SoalKuis.query.filter_by(
        kuisid=kuis.id
    ).order_by(SoalKuis.urutan).all()

    terjawab_ids = {
        j.soal_kuisid
        for j in UserJawabanKuis.query.filter_by(
            userid=user_id, attempt=user_kuis.attempt
        ).all()
    }

    next_soal = next((s for s in soal_list if s.id not in terjawab_ids), None)

    kuis_data = {
        "id":            kuis.id,
        "babid":         kuis.babid,
        "judul":         kuis.judul,
        "passing_score": kuis.passing_score,
        "total_soal":    len(soal_list),
        "sudah_dijawab": len(terjawab_ids),
        "attempt":       user_kuis.attempt,
        "is_completed":  user_kuis.is_completed,
        "nilai":         user_kuis.nilai,
    }

    return jsonify({
        "kuis":       kuis_data,
        "soal_aktif": next_soal.to_dict(hide_answer=True) if next_soal else None
    }), 200


# ──────────────────────────────────────────────
# GET /api/bab/<id>/kuis/review
# Hanya bisa diakses kalau kuis sudah selesai (attempt terbaru)
# ──────────────────────────────────────────────
@bab_bp.route("/<int:bab_id>/kuis/review", methods=["GET"])
@jwt_required()
def review_kuis(bab_id):
    user_id = int(get_jwt_identity())

    kuis = Kuis.query.filter_by(babid=bab_id).first_or_404()

    user_kuis = UserKuis.query.filter_by(
        userid=user_id, kuisid=kuis.id
    ).first()

    if not user_kuis or not user_kuis.is_completed:
        return jsonify({
            "message": "Selesaikan kuis ini terlebih dahulu"
        }), 403

    soal_list = SoalKuis.query.filter_by(
        kuisid=kuis.id
    ).order_by(SoalKuis.urutan).all()

    latest_attempt = user_kuis.attempt

    jawaban_map = {
        j.soal_kuisid: j
        for j in UserJawabanKuis.query.filter_by(
            userid=user_id, attempt=latest_attempt
        ).all()
    }

    result = []
    for s in soal_list:
        j = jawaban_map.get(s.id)
        soal_data = s.to_dict(hide_answer=False)
        soal_data["jawaban_user"] = j.jawaban_user if j else None
        soal_data["is_correct"]   = j.is_correct if j else None
        result.append(soal_data)

    kuis_data = {
        "id":           kuis.id,
        "babid":        kuis.babid,
        "judul":        kuis.judul,
        "attempt":      latest_attempt,
        "is_completed": user_kuis.is_completed,
        "nilai":        user_kuis.nilai,
    }

    return jsonify({
        "kuis":  kuis_data,
        "total": len(result),
        "soal":  result
    }), 200


# ──────────────────────────────────────────────
# GET /api/bab/<id>/topik
# ──────────────────────────────────────────────
@bab_bp.route("/<int:bab_id>/topik", methods=["GET"])
@jwt_required()
def get_topik_by_bab(bab_id):
    user_id = int(get_jwt_identity())

    bab      = Bab.query.get_or_404(bab_id)
    user_bab = UserBab.query.filter_by(userid=user_id, babid=bab_id).first()

    if not user_bab or user_bab.locked:
        return jsonify({"message": "Bab ini masih terkunci"}), 403

    topik_list = Topik.query.filter_by(babid=bab_id).order_by(Topik.urutan).all()

    result = []
    for t in topik_list:
        materi_list = Materi.query.filter_by(
            topikid=t.id
        ).order_by(Materi.urutan).all()

        materi_result = []
        for m in materi_list:
            user_materi = UserMateri.query.filter_by(
                userid=user_id, materiid=m.id
            ).first()

            materi_data                 = m.to_dict()
            materi_data["is_completed"] = user_materi.is_completed if user_materi else False
            materi_result.append(materi_data)

        topik_data           = t.to_dict()
        topik_data["materi"] = materi_result
        result.append(topik_data)

    kuis = Kuis.query.filter_by(babid=bab_id).first()
    user_kuis = UserKuis.query.filter_by(
        userid=user_id, kuisid=kuis.id
    ).first() if kuis else None

    bab_data                 = bab.to_dict()
    bab_data["locked"]       = user_bab.locked
    bab_data["is_completed"] = user_kuis.is_completed if user_kuis else False
    bab_data["nilai"]        = user_kuis.nilai if user_kuis else 0

    return jsonify({
        "bab":   bab_data,
        "total": len(result),
        "topik": result
    }), 200