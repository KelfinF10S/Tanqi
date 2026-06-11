from flask import Blueprint, jsonify
from flask_jwt_extended import jwt_required, get_jwt_identity
from models.models import Bab, Soal, UserBab, UserJawaban
from app import db

bab_bp = Blueprint("bab", __name__)


# ──────────────────────────────────────────────
# GET /api/bab
# ──────────────────────────────────────────────
@bab_bp.route("/", methods=["GET"])
@jwt_required()
def get_all_bab():
    user_id  = get_jwt_identity()
    bab_list = Bab.query.order_by(Bab.id).all()

    result = []
    for b in bab_list:
        user_bab = UserBab.query.filter_by(userid=user_id, babid=b.id).first()

        if not user_bab:
            user_bab = UserBab(
                userid=user_id,
                babid=b.id,
                locked=(b.id != 1)  # bab 1 otomatis unlock
            )
            db.session.add(user_bab)
            db.session.commit()

        soal_ids      = [s.id for s in Soal.query.filter_by(babid=b.id).all()]
        total_soal    = len(soal_ids)
        sudah_dijawab = UserJawaban.query.filter(
            UserJawaban.userid == user_id,
            UserJawaban.soalid.in_(soal_ids)
        ).count() if soal_ids else 0

        bab_data                  = b.to_dict()
        bab_data["locked"]        = user_bab.locked
        bab_data["is_completed"]  = user_bab.is_completed
        bab_data["total_soal"]    = total_soal
        bab_data["sudah_dijawab"] = sudah_dijawab
        bab_data["sisa_soal"]     = total_soal - sudah_dijawab
        result.append(bab_data)

    return jsonify({"total": len(result), "data": result}), 200


# ──────────────────────────────────────────────
# GET /api/bab/<id>/soal
# ──────────────────────────────────────────────
@bab_bp.route("/<int:bab_id>/soal", methods=["GET"])
@jwt_required()
def get_soal_by_bab(bab_id):
    user_id = get_jwt_identity()

    bab = Bab.query.get_or_404(bab_id)

    user_bab = UserBab.query.filter_by(userid=user_id, babid=bab_id).first()
    if not user_bab or user_bab.locked:
        return jsonify({"message": "Bab ini masih terkunci"}), 403

    soal_list = Soal.query.filter_by(babid=bab_id).all()
    soal_ids  = [s.id for s in soal_list]

    answered_ids = {
        uj.soalid for uj in UserJawaban.query.filter(
            UserJawaban.userid == user_id,
            UserJawaban.soalid.in_(soal_ids)
        ).all()
    }

    result = []
    for s in soal_list:
        soal_data                  = s.to_dict(hide_answer=True)
        soal_data["sudah_dijawab"] = s.id in answered_ids
        result.append(soal_data)

    bab_data                  = bab.to_dict()
    bab_data["locked"]        = user_bab.locked
    bab_data["is_completed"]  = user_bab.is_completed
    bab_data["total_soal"]    = len(soal_list)
    bab_data["sudah_dijawab"] = len(answered_ids)
    bab_data["sisa_soal"]     = len(soal_list) - len(answered_ids)

    return jsonify({
        "bab":   bab_data,
        "total": len(result),
        "soal":  result
    }), 200