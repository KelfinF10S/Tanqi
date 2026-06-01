from flask import Blueprint, jsonify
from flask_jwt_extended import jwt_required, get_jwt_identity
from models.models import Bab, Soal, UserJawaban

bab_bp = Blueprint("bab", __name__)


# ──────────────────────────────────────────────
# GET /api/bab
# Ambil semua bab (butuh login)
# ──────────────────────────────────────────────
@bab_bp.route("/", methods=["GET"])
@jwt_required()
def get_all_bab():
    bab_list = Bab.query.order_by(Bab.id).all()

    return jsonify({
        "total": len(bab_list),
        "data":  [b.to_dict() for b in bab_list]
    }), 200


# ──────────────────────────────────────────────
# GET /api/bab/<id>/soal
# Ambil semua soal dalam bab tertentu
# Jawaban benar DISEMBUNYIKAN dari response
# ──────────────────────────────────────────────
@bab_bp.route("/<int:bab_id>/soal", methods=["GET"])
@jwt_required()
def get_soal_by_bab(bab_id):
    user_id = get_jwt_identity()

    bab = Bab.query.get_or_404(bab_id)

    if bab.locked:
        return jsonify({"message": "Bab ini masih terkunci"}), 403

    soal_list = Soal.query.filter_by(babid=bab_id).all()

    # Tandai soal yang sudah dijawab user
    answered_ids = {
        uj.soalid for uj in UserJawaban.query.filter_by(userid=user_id).all()
    }

    result = []
    for s in soal_list:
        soal_data            = s.to_dict(hide_answer=True)   # jawaban_benar tersembunyi
        soal_data["sudah_dijawab"] = s.id in answered_ids
        result.append(soal_data)

    return jsonify({
        "bab":   bab.to_dict(),
        "total": len(result),
        "soal":  result
    }), 200
