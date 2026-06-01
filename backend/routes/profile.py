from flask import Blueprint, jsonify
from flask_jwt_extended import jwt_required, get_jwt_identity
from models.models import User, UserJawaban, Soal

profile_bp = Blueprint("profile", __name__)


# ──────────────────────────────────────────────
# GET /api/profile
# Statistik lengkap user yang sedang login
# Header: Authorization: Bearer <token>
# ──────────────────────────────────────────────
@profile_bp.route("/", methods=["GET"])
@jwt_required()
def get_profile():
    user_id = get_jwt_identity()
    user    = User.query.get_or_404(user_id)

    # Hitung statistik jawaban
    semua_jawaban  = UserJawaban.query.filter_by(userid=user_id).all()
    total_dijawab  = len(semua_jawaban)
    total_benar    = sum(1 for j in semua_jawaban if j.is_correct)
    total_salah    = total_dijawab - total_benar
    total_xp       = sum(j.xp_didapat for j in semua_jawaban)

    akurasi = round((total_benar / total_dijawab * 100), 1) if total_dijawab > 0 else 0.0

    # Riwayat jawaban terbaru (10 terakhir)
    riwayat = (
        UserJawaban.query
        .filter_by(userid=user_id)
        .order_by(UserJawaban.anwsered_at.desc())
        .limit(10)
        .all()
    )

    return jsonify({
        "user": user.to_dict(),
        "statistik": {
            "total_soal_dijawab": total_dijawab,
            "total_benar":        total_benar,
            "total_salah":        total_salah,
            "total_xp":           total_xp,
            "akurasi_persen":     akurasi,
        },
        "riwayat_jawaban": [j.to_dict() for j in riwayat]
    }), 200
