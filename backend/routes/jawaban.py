from flask import Blueprint, request, jsonify
from flask_jwt_extended import jwt_required, get_jwt_identity
from extensions import db
from models.models import User, Soal, UserJawaban, Bab

jawaban_bp = Blueprint("jawaban", __name__)


# ──────────────────────────────────────────────
# POST /api/jawaban
# Body: { "soal_id": 1, "jawaban": "B" }
# Header: Authorization: Bearer <token>
# ──────────────────────────────────────────────
@jawaban_bp.route("/", methods=["POST"])
@jwt_required()
def submit_jawaban():
    user_id = get_jwt_identity()
    data    = request.get_json()

    soal_id       = data.get("soal_id")
    jawaban_user  = str(data.get("jawaban", "")).upper().strip()

    if not soal_id or not jawaban_user:
        return jsonify({"message": "soal_id dan jawaban wajib diisi"}), 400

    if jawaban_user not in ("A", "B", "C", "D"):
        return jsonify({"message": "Jawaban harus A, B, C, atau D"}), 400

    soal = Soal.query.get(soal_id)
    if not soal:
        return jsonify({"message": "Soal tidak ditemukan"}), 404

    # Cek apakah sudah pernah menjawab soal ini
    existing = UserJawaban.query.filter_by(userid=user_id, soalid=soal_id).first()
    if existing:
        return jsonify({"message": "Soal ini sudah pernah dijawab"}), 409

    # Tentukan benar/salah & XP
    is_correct = jawaban_user == soal.jawaban_benar.upper()
    xp_didapat = soal.xp_reward if is_correct else 0

    # Simpan jawaban
    new_jawaban = UserJawaban(
        jawaban_user = jawaban_user,
        is_correct   = is_correct,
        xp_didapat   = xp_didapat,
        userid       = user_id,
        soalid       = soal_id,
    )
    db.session.add(new_jawaban)

    # Update XP & level user jika benar
    if is_correct:
        user     = User.query.get(user_id)
        user.xp += xp_didapat
        user.level = _hitung_level(user.xp)

    db.session.commit()

    return jsonify({
        "message":      "Jawaban berhasil disimpan",
        "is_correct":   is_correct,
        "jawaban_benar": soal.jawaban_benar.upper(),
        "xp_didapat":   xp_didapat,
        "data":         new_jawaban.to_dict()
    }), 201


# ──────────────────────────────────────────────
# DELETE /api/jawaban/reset/<babid>
# Reset semua jawaban user di bab tertentu
# + rollback XP dari soal-soal bab tersebut
# Header: Authorization: Bearer <token>
# ──────────────────────────────────────────────
@jawaban_bp.route("/reset/<int:babid>", methods=["DELETE"])
@jwt_required()
def reset_jawaban_bab(babid):
    user_id = get_jwt_identity()

    bab = Bab.query.get_or_404(babid)

    if not bab.is_completed:
        return jsonify({"message": "Bab belum selesai dikerjakan"}), 400

    soal_ids = [s.id for s in Soal.query.filter_by(babid=babid).all()]

    # Hapus semua jawaban user di bab ini
    UserJawaban.query.filter(
        UserJawaban.userid  == user_id,
        UserJawaban.soalid.in_(soal_ids)
    ).delete(synchronize_session="fetch")

    # Tandai bab siap dikerjakan ulang, naikkan attempt
    bab.is_completed  = False
    bab.total_attempt += 1

    # XP TIDAK dirollback
    db.session.commit()

    return jsonify({
        "message":       f"Bab {babid} siap dikerjakan ulang",
        "babid":         babid,
        "total_attempt": bab.total_attempt,
        "xp_note":       "XP tidak akan bertambah pada attempt berikutnya",
    }), 200


def _hitung_level(xp: int) -> int:
    if xp < 100:
        return 1
    elif xp < 300:
        return 2
    elif xp < 600:
        return 3
    elif xp < 1000:
        return 4
    else:
        return 5
