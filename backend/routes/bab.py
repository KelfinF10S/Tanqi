from flask import Blueprint, jsonify
from flask_jwt_extended import jwt_required, get_jwt_identity
from extensions import db
from models.models import Bab, Topik, Materi, Soal, UserBab, UserMateri, UserJawaban

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

        soal_ids      = [s.id for s in Soal.query.filter_by(babid=b.id).all()]
        total_soal    = len(soal_ids)

        materi_list = Materi.query.filter_by(babid=b.id).all()

        sudah_dijawab = 0

        for materi in materi_list:

            user_materi = UserMateri.query.filter_by(
                userid=user_id,
                materiid=materi.id
            ).first()

            current_attempt = user_materi.attempt if user_materi else 1

            soal_ids_materi = [
                s.id for s in Soal.query.filter_by(materiid=materi.id).all()
            ]

            sudah_dijawab += UserJawaban.query.filter(
                UserJawaban.userid == user_id,
                UserJawaban.soalid.in_(soal_ids_materi),
                UserJawaban.attempt == current_attempt
            ).count()

        bab_data                  = b.to_dict()
        bab_data["locked"]        = user_bab.locked
        bab_data["is_completed"]  = user_bab.is_completed
        bab_data["nilai"]         = user_bab.nilai
        bab_data["total_soal"]    = total_soal
        bab_data["sudah_dijawab"] = sudah_dijawab
        bab_data["sisa_soal"]     = total_soal - sudah_dijawab
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

        soal_ids        = [s.id for s in Soal.query.filter_by(materiid=m.id).all()]
        total_soal      = len(soal_ids)
        current_attempt = user_materi.attempt if user_materi else 1

        sudah_dijawab = UserJawaban.query.filter(
            UserJawaban.userid == user_id,
            UserJawaban.soalid.in_(soal_ids),
            UserJawaban.attempt == current_attempt
        ).count()

        materi_data                  = m.to_dict()
        materi_data["is_completed"]  = user_materi.is_completed if user_materi else False
        materi_data["xp_didapat"]    = user_materi.xp_didapat   if user_materi else 0
        materi_data["attempt"]       = user_materi.attempt      if user_materi else 1
        materi_data["total_soal"]    = total_soal
        materi_data["sudah_dijawab"] = sudah_dijawab
        materi_data["sisa_soal"]     = total_soal - sudah_dijawab
        result.append(materi_data)

    bab_data                 = bab.to_dict()
    bab_data["locked"]       = user_bab.locked
    bab_data["is_completed"] = user_bab.is_completed
    bab_data["nilai"]        = user_bab.nilai

    return jsonify({
        "bab":    bab_data,
        "total":  len(result),
        "materi": result
    }), 200


# ──────────────────────────────────────────────
# GET /api/bab/materi/<id>/soal
# ──────────────────────────────────────────────
@bab_bp.route("/materi/<int:materi_id>/soal", methods=["GET"])
@jwt_required()
def get_soal_by_materi(materi_id):
    user_id = int(get_jwt_identity())

    materi = Materi.query.get_or_404(materi_id)

    user_bab = UserBab.query.filter_by(
        userid=user_id,
        babid=materi.babid
    ).first()

    if not user_bab or user_bab.locked:
        return jsonify({"message": "Bab ini masih terkunci"}), 403

    # ─────────────────────────────────────
    # Buat UserMateri jika belum ada
    # ─────────────────────────────────────
    user_materi = UserMateri.query.filter_by(
        userid=user_id,
        materiid=materi_id
    ).first()

    if not user_materi:
        user_materi = UserMateri(
            userid=user_id,
            materiid=materi_id,
            is_completed=False,
            xp_didapat=0,
            attempt=1
        )
        db.session.add(user_materi)
        db.session.commit()

    soal_list = Soal.query.filter_by(
        materiid=materi_id
    ).all()

    soal_ids = [s.id for s in soal_list]

    current_attempt = user_materi.attempt

    answered_ids = {
        uj.soalid
        for uj in UserJawaban.query.filter(
            UserJawaban.userid == user_id,
            UserJawaban.soalid.in_(soal_ids),
            UserJawaban.attempt == current_attempt
        ).all()
    }

    result = []

    for s in soal_list:
        soal_data = s.to_dict(hide_answer=True)
        soal_data["sudah_dijawab"] = s.id in answered_ids
        result.append(soal_data)

    materi_data = materi.to_dict()
    materi_data["is_completed"] = user_materi.is_completed
    materi_data["xp_didapat"] = user_materi.xp_didapat
    materi_data["attempt"] = user_materi.attempt
    materi_data["total_soal"] = len(soal_list)
    materi_data["sudah_dijawab"] = len(answered_ids)
    materi_data["sisa_soal"] = len(soal_list) - len(answered_ids)

    return jsonify({
        "materi": materi_data,
        "total": len(result),
        "soal": result
    }), 200


# ──────────────────────────────────────────────
# GET /api/bab/materi/<id>/review
# Hanya bisa diakses kalau materi sudah selesai
# ──────────────────────────────────────────────
@bab_bp.route("/materi/<int:materi_id>/review", methods=["GET"])
@jwt_required()
def review_materi(materi_id):
    user_id = int(get_jwt_identity())

    materi = Materi.query.get_or_404(materi_id)

    user_materi = UserMateri.query.filter_by(
        userid=user_id,
        materiid=materi_id
    ).first()

    if not user_materi or not user_materi.is_completed:
        return jsonify({
            "message": "Selesaikan materi ini terlebih dahulu"
        }), 403

    # ← BARU: ambil UserBab
    user_bab = UserBab.query.filter_by(
        userid=user_id,
        babid=materi.babid
    ).first()

    soal_list = Soal.query.filter_by(materiid=materi_id).all()
    soal_ids = [s.id for s in soal_list]

    latest_attempt = user_materi.attempt

    jawaban_map = {
        uj.soalid: uj
        for uj in UserJawaban.query.filter(
            UserJawaban.userid == user_id,
            UserJawaban.soalid.in_(soal_ids),
            UserJawaban.attempt == latest_attempt
        ).all()
    }

    result = []
    for s in soal_list:
        uj = jawaban_map.get(s.id)
        soal_data = s.to_dict(hide_answer=False)
        soal_data["jawaban_user"] = uj.jawaban_user if uj else None
        soal_data["is_correct"] = uj.is_correct if uj else None
        soal_data["penjelasan"] = s.penjelasan if (uj and uj.is_correct) else None
        result.append(soal_data)

    materi_data = materi.to_dict()
    materi_data["is_completed"] = user_materi.is_completed
    materi_data["xp_didapat"] = user_materi.xp_didapat
    materi_data["attempt"] = latest_attempt

    # ← BARU: sertakan bab_data
    bab_data = {
        "is_completed": user_bab.is_completed if user_bab else False,
        "nilai": user_bab.nilai if user_bab else 0,
    }

    return jsonify({
        "materi": materi_data,
        "bab": bab_data,      # ← ditambahkan
        "total": len(result),
        "soal": result
    }), 200


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
        materi_list = Materi.query.filter_by(topikid=t.id).order_by(Materi.urutan).all()

        materi_result = []
        for m in materi_list:
            user_materi = UserMateri.query.filter_by(
                userid=user_id, materiid=m.id
            ).first()

            soal_ids        = [s.id for s in Soal.query.filter_by(materiid=m.id).all()]
            total_soal      = len(soal_ids)
            current_attempt = user_materi.attempt if user_materi else 1

            sudah_dijawab = UserJawaban.query.filter(
                UserJawaban.userid == user_id,
                UserJawaban.soalid.in_(soal_ids),
                UserJawaban.attempt == current_attempt
            ).count()

            materi_data                  = m.to_dict()
            materi_data["is_completed"]  = user_materi.is_completed if user_materi else False
            materi_data["xp_didapat"]    = user_materi.xp_didapat   if user_materi else 0
            materi_data["attempt"]       = user_materi.attempt      if user_materi else 1
            materi_data["total_soal"]    = total_soal
            materi_data["sudah_dijawab"] = sudah_dijawab
            materi_data["sisa_soal"]     = total_soal - sudah_dijawab
            materi_result.append(materi_data)

        topik_data           = t.to_dict()
        topik_data["materi"] = materi_result
        result.append(topik_data)

    bab_data                 = bab.to_dict()
    bab_data["locked"]       = user_bab.locked
    bab_data["is_completed"] = user_bab.is_completed
    bab_data["nilai"]        = user_bab.nilai

    return jsonify({
        "bab":   bab_data,
        "total": len(result),
        "topik": result
    }), 200