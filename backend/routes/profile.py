from flask import Blueprint, jsonify
from flask_jwt_extended import jwt_required, get_jwt_identity
from extensions import db
from models.models import User, UserJawaban, UserBab, Soal

profile_bp = Blueprint("profile", __name__)


# ──────────────────────────────────────────────
# GET /api/profile
# ──────────────────────────────────────────────
@profile_bp.route("/", methods=["GET"])
@jwt_required()
def get_profile():
    user_id = int(get_jwt_identity())
    user    = User.query.get_or_404(user_id)

    # Bab selesai langsung dari UserBab
    bab_selesai = UserBab.query.filter_by(
        userid=user_id, is_completed=True
    ).count()

    # Nilai per bab
    user_bab_list = UserBab.query.filter_by(userid=user_id).all()
    nilai_per_bab = [
        {"babid": ub.babid, "nilai": ub.nilai, "is_completed": ub.is_completed}
        for ub in user_bab_list
    ]

    # Statistik jawaban
    semua_jawaban = UserJawaban.query.filter_by(userid=user_id).all()
    total_dijawab = len(semua_jawaban)
    total_benar   = sum(1 for j in semua_jawaban if j.is_correct)
    total_salah   = total_dijawab - total_benar
    total_xp      = sum(j.xp_didapat for j in semua_jawaban)
    akurasi       = round((total_benar / total_dijawab * 100), 1) if total_dijawab > 0 else 0.0

    # Riwayat 10 jawaban terakhir
    riwayat = (
        UserJawaban.query
        .filter_by(userid=user_id)
        .order_by(UserJawaban.created_at.desc())
        .limit(10)
        .all()
    )

    user_data              = user.to_dict()
    user_data["bab_selesai"] = bab_selesai

    return jsonify({
        "user": user_data,
        "statistik": {
            "total_soal_dijawab": total_dijawab,
            "total_benar":        total_benar,
            "total_salah":        total_salah,
            "total_xp":           total_xp,
            "akurasi_persen":     akurasi,
        },
        "nilai_per_bab":    nilai_per_bab,
        "riwayat_jawaban":  [j.to_dict() for j in riwayat]
    }), 200


# # ──────────────────────────────────────────────
# # GET /api/profile/users
# # Ambil semua user
# # ──────────────────────────────────────────────
# @profile_bp.route("/users", methods=["GET"])
# @jwt_required()
# def get_users():
#     users = User.query.order_by(User.level.desc(), User.xp.desc()).all()

#     result = []

#     for user in users:
#         bab_selesai = UserBab.query.filter_by(
#             userid=user.id,
#             is_completed=True
#         ).count()

#         result.append({
#             "id": user.id,
#             "username": user.username,
#             "level": user.level,
#             "xp": user.xp,
#             "bab_selesai": bab_selesai,
#         })

#     return jsonify({
#         "total": len(result),
#         "data": result
#     }), 200