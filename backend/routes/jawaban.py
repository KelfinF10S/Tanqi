# routes/jawaban.py

from flask import Blueprint, request, jsonify
from flask_jwt_extended import jwt_required, get_jwt_identity
from extensions import db
from models.models import (
    Kuis, SoalKuis, UserKuis, UserJawabanKuis, UserBab, User
)


jawaban_bp = Blueprint("jawaban", __name__)


# ──────────────────────────────────────────────
# Helper: cek kebenaran jawaban berdasarkan tipe soal
# ──────────────────────────────────────────────
def _cek_jawaban(tipe: str, jawaban_benar: dict, jawaban_user):
    if tipe == "multiple_choice":
        benar = jawaban_benar.get("benar", "")
        return str(jawaban_user).upper().strip() == str(benar).upper().strip()

    elif tipe == "drag_drop":
        # jawaban_benar & jawaban_user berbentuk dict {item: target}
        if not isinstance(jawaban_user, dict):
            return False
        return jawaban_user == jawaban_benar

    elif tipe == "tap_object":
        # jawaban_benar = {"correct_ids": [...]}, jawaban_user = list id
        if not isinstance(jawaban_user, list):
            return False
        correct_ids = jawaban_benar.get("correct_ids", [])
        return set(jawaban_user) == set(correct_ids)

    return False


# ──────────────────────────────────────────────
# Helper: hitung nilai kuis dari attempt terbaru
# ──────────────────────────────────────────────
def _hitung_nilai_kuis(user_id: int, kuis_id: int):
    """
    Return: (nilai, total_benar, total_soal)
    """
    user_kuis = UserKuis.query.filter_by(userid=user_id, kuisid=kuis_id).first()
    if not user_kuis:
        return 0, 0, 0

    current_attempt = user_kuis.attempt

    soal_ids = [s.id for s in SoalKuis.query.filter_by(kuisid=kuis_id).all()]
    total_soal = len(soal_ids)

    if total_soal == 0:
        return 0, 0, 0

    jawaban = UserJawabanKuis.query.filter(
        UserJawabanKuis.userid == user_id,
        UserJawabanKuis.attempt == current_attempt,
        UserJawabanKuis.soal_kuisid.in_(soal_ids)
    ).all()

    total_benar = sum(1 for j in jawaban if j.is_correct)
    nilai = round((total_benar / total_soal) * 100, 1) if total_soal > 0 else 0

    return nilai, total_benar, total_soal


# ──────────────────────────────────────────────
# Helper: cek progress kuis, update UserKuis & unlock bab berikutnya
# ──────────────────────────────────────────────
def _cek_progress_kuis(user_id: int, kuis_id: int, bab_id: int):
    """
    Return: (kuis_selesai, bab_selesai, nilai)
    """
    user_kuis = UserKuis.query.filter_by(userid=user_id, kuisid=kuis_id).first()
    if not user_kuis:
        return False, False, 0

    # Ambil passing_score dari Kuis (dulu di-hardcode 70 di sini)
    kuis = Kuis.query.get(kuis_id)
    passing_score = kuis.passing_score if kuis else 70

    current_attempt = user_kuis.attempt

    soal_ids = [s.id for s in SoalKuis.query.filter_by(kuisid=kuis_id).all()]
    total_soal = len(soal_ids)

    if total_soal == 0:
        return False, False, 0

    total_dijawab = UserJawabanKuis.query.filter(
        UserJawabanKuis.userid == user_id,
        UserJawabanKuis.attempt == current_attempt,
        UserJawabanKuis.soal_kuisid.in_(soal_ids)
    ).count()

    if total_dijawab < total_soal:
        db.session.commit()
        return False, False, 0

    # ==========================================
    # Semua soal attempt ini sudah dijawab -> hitung nilai
    # ==========================================
    nilai, total_benar, _ = _hitung_nilai_kuis(user_id, kuis_id)

    user_kuis.is_completed = True
    if nilai > user_kuis.nilai:
        user_kuis.nilai = nilai

    bab_selesai = user_kuis.nilai >= passing_score

    if bab_selesai:
        user_bab = UserBab.query.filter_by(userid=user_id, babid=bab_id).first()

        if user_bab:
            bab_berikutnya = UserBab.query.filter_by(
                userid=user_id,
                babid=bab_id + 1
            ).first()

            if bab_berikutnya and bab_berikutnya.locked:
                bab_berikutnya.locked = False

    db.session.commit()

    return True, bab_selesai, user_kuis.nilai

# ──────────────────────────────────────────────
# Helper: cek apakah user PERNAH benar soal ini (attempt manapun)
# ──────────────────────────────────────────────
def _pernah_benar(user_id: int, soal_kuis_id: int) -> bool:
    return db.session.query(
        UserJawabanKuis.query.filter_by(
            userid=user_id,
            soal_kuisid=soal_kuis_id,
            is_correct=True
        ).exists()
    ).scalar()


# ──────────────────────────────────────────────
# POST /api/kuis/jawaban
# Body: { "soal_kuis_id": 1, "jawaban": ... }
# jawaban:
#   - multiple_choice -> string ("A"/"B"/"C"/"D")
#   - drag_drop        -> dict {"item": "target", ...}
#   - tap_object        -> list ["id1", "id2", ...]
# ──────────────────────────────────────────────
@jawaban_bp.route("/jawaban", methods=["POST"])
@jwt_required()
def submit_jawaban_kuis():
    user_id = int(get_jwt_identity())
    data = request.get_json()

    soal_kuis_id = data.get("soal_kuis_id")
    jawaban_user = data.get("jawaban")

    if soal_kuis_id is None or jawaban_user is None:
        return jsonify({"message": "soal_kuis_id dan jawaban wajib diisi"}), 400

    soal = SoalKuis.query.get(soal_kuis_id)
    if not soal:
        return jsonify({"message": "Soal tidak ditemukan"}), 404

    kuis = Kuis.query.get(soal.kuisid)

    # Pastikan user sudah mulai kuis ini
    user_kuis = UserKuis.query.filter_by(userid=user_id, kuisid=kuis.id).first()
    if not user_kuis:
        return jsonify({"message": "Mulai kuis terlebih dahulu"}), 400

    current_attempt = user_kuis.attempt

    # ─────────────────────────────────────
    # Validasi urutan: soal sebelumnya (urutan lebih kecil) wajib
    # sudah terjawab semua pada attempt ini
    # ─────────────────────────────────────
    soal_sebelumnya_ids = [
        s.id for s in SoalKuis.query.filter(
            SoalKuis.kuisid == kuis.id,
            SoalKuis.urutan < soal.urutan
        ).all()
    ]

    if soal_sebelumnya_ids:
        terjawab_sebelumnya = {
            j.soal_kuisid
            for j in UserJawabanKuis.query.filter(
                UserJawabanKuis.userid == user_id,
                UserJawabanKuis.attempt == current_attempt,
                UserJawabanKuis.soal_kuisid.in_(soal_sebelumnya_ids)
            ).all()
        }
        belum_terjawab = set(soal_sebelumnya_ids) - terjawab_sebelumnya
        if belum_terjawab:
            return jsonify({
                "message": "Selesaikan soal sebelumnya terlebih dahulu"
            }), 400

    # ─────────────────────────────────────
    # Cek soal ini belum dijawab pada attempt yang sama
    # ─────────────────────────────────────
    existing = UserJawabanKuis.query.filter_by(
        userid=user_id,
        soal_kuisid=soal_kuis_id,
        attempt=current_attempt
    ).first()

    if existing:
        return jsonify({
            "message": "Soal ini sudah dijawab pada attempt ini"
        }), 409

    is_correct = _cek_jawaban(soal.tipe, soal.jawaban_benar, jawaban_user)

    # Cek riwayat SEBELUM menyimpan jawaban baru ini
    sudah_pernah_benar = _pernah_benar(user_id, soal_kuis_id)


    new_jawaban = UserJawabanKuis(
        userid=user_id,
        soal_kuisid=soal_kuis_id,
        jawaban_user=jawaban_user,
        is_correct=is_correct,
        attempt=current_attempt
    )
    db.session.add(new_jawaban)
    db.session.commit()

    # ─────────────────────────────────────
    # XP: hanya diberikan kalau benar DAN belum pernah benar sebelumnya
    # ─────────────────────────────────────
    xp_earned = 0
    if is_correct and not sudah_pernah_benar:
        xp_earned = kuis.xp_per_soal
        user = User.query.get(user_id)
        user.xp += xp_earned
        db.session.commit()

    kuis_selesai, bab_selesai, nilai = _cek_progress_kuis(
        user_id=user_id,
        kuis_id=kuis.id,
        bab_id=kuis.babid
    )

    return jsonify({
        "message": "Jawaban berhasil disimpan",
        "is_correct": is_correct,
        "jawaban_benar": soal.jawaban_benar,
        "penjelasan": soal.penjelasan if is_correct else None,
        "kuis_selesai": kuis_selesai,
        "bab_selesai": bab_selesai,
        "nilai": nilai,
        "xp_earned": xp_earned,  
        "total_xp": User.query.get(user_id).xp,  
        "data": new_jawaban.to_dict()
    }), 201


# ──────────────────────────────────────────────
# DELETE /api/kuis/reset/<bab_id>
# Mulai ulang kuis pada bab tsb (attempt baru)
# ──────────────────────────────────────────────
@jawaban_bp.route("/reset/<int:bab_id>", methods=["DELETE"])
@jwt_required()
def reset_kuis(bab_id):
    user_id = int(get_jwt_identity())

    kuis = Kuis.query.filter_by(babid=bab_id).first_or_404()

    user_kuis = UserKuis.query.filter_by(
        userid=user_id,
        kuisid=kuis.id
    ).first_or_404()

    if not user_kuis.is_completed:
        return jsonify({
            "message": "Kuis belum selesai dikerjakan"
        }), 400

    user_kuis.is_completed = False
    user_kuis.attempt += 1

    db.session.commit()

    return jsonify({
        "message": "Kuis siap dikerjakan ulang",
        "kuisid": kuis.id,
        "babid": bab_id,
        "attempt": user_kuis.attempt
    }), 200

