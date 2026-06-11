from flask import Blueprint, request, jsonify
from flask_jwt_extended import create_access_token, jwt_required, get_jwt_identity
from werkzeug.security import generate_password_hash, check_password_hash
from extensions import db
from models.models import User, UserJawaban, Soal
from sqlalchemy import func


auth_bp = Blueprint("auth", __name__)

# ──────────────────────────────────────────────
# POST /api/auth/register
# Body: { "username": "...", "password": "..." }
# ──────────────────────────────────────────────
@auth_bp.route("/register", methods=["POST"])
def register():
    data = request.get_json()

    username = data.get("username", "").strip()
    password = data.get("password", "").strip()

    if not username or not password:
        return jsonify({"message": "Username dan password wajib diisi"}), 400

    if User.query.filter_by(username=username).first():
        return jsonify({"message": "Username sudah digunakan"}), 409

    hashed_pw = generate_password_hash(password)
    new_user  = User(username=username, password=hashed_pw)

    db.session.add(new_user)
    db.session.commit()

    return jsonify({
        "message": "Registrasi berhasil",
        "user": new_user.to_dict()
    }), 201


# ──────────────────────────────────────────────
# POST /api/auth/login
# Body: { "username": "...", "password": "..." }
# ──────────────────────────────────────────────
@auth_bp.route("/login", methods=["POST"])
def login():
    data = request.get_json()

    username = data.get("username", "").strip()
    password = data.get("password", "").strip()

    user = User.query.filter_by(username=username).first()

    if not user or not check_password_hash(user.password, password):
        return jsonify({"message": "Username atau password salah"}), 401

    access_token = create_access_token(identity=str(user.id))

    return jsonify({
        "message":      "Login berhasil",
        "access_token": access_token,
        "user":         user.to_dict()
    }), 200


# ──────────────────────────────────────────────
# GET /api/auth/me
# Header: Authorization: Bearer <token>
# ──────────────────────────────────────────────

@auth_bp.route("/me", methods=["GET"])
@jwt_required()
def me():
    user_id = int(get_jwt_identity())
    user = User.query.get_or_404(user_id)

    total_soal_per_bab = (
        db.session.query(
            Soal.babid,
            func.count(Soal.id)
        )
        .group_by(Soal.babid)
        .all()
    )

    soal_user_dijawab = (
        db.session.query(
            Soal.babid,
            func.count(func.distinct(UserJawaban.soalid))
        )
        .join(
            UserJawaban,
            Soal.id == UserJawaban.soalid
        )
        .filter(
            UserJawaban.userid == user_id
        )
        .group_by(
            Soal.babid
        )
        .all()
    )

    dict_total = {
        bab_id: total
        for bab_id, total in total_soal_per_bab
    }

    dict_user = {
        bab_id: dijawab
        for bab_id, dijawab in soal_user_dijawab
    }

    bab_selesai = 0

    for bab_id, total in dict_total.items():
        if dict_user.get(bab_id, 0) >= total:
            bab_selesai += 1

    user_data = user.to_dict()
    user_data["bab_selesai"] = bab_selesai

    return jsonify({
        "user": user_data
    }), 200
    user_id = get_jwt_identity()
    user    = User.query.get_or_404(user_id)

    return jsonify({"user": user.to_dict()}), 200


# ──────────────────────────────────────────────
# PUT /api/auth/update-username
# Authorization: Bearer TOKEN
# ──────────────────────────────────────────────
@auth_bp.route("/update-username", methods=["PUT"])
@jwt_required()
def update_username():
    user_id = get_jwt_identity()
    user = User.query.get_or_404(user_id)

    data = request.get_json()

    new_username = data.get("username", "").strip()

    # validasi kosong
    if not new_username:
        return jsonify({
            "message": "Username wajib diisi"
        }), 400

    # validasi panjang minimal
    if len(new_username) < 3:
        return jsonify({
            "message": "Username minimal 3 karakter"
        }), 400

    # cek apakah username sudah dipakai user lain
    username_exist = User.query.filter(
        User.username == new_username,
        User.id != user.id
    ).first()

    if username_exist:
        return jsonify({
            "message": "Username sudah digunakan"
        }), 409

    # update username
    user.username = new_username

    db.session.commit()

    return jsonify({
        "message": "Username berhasil diperbarui",
        "user": user.to_dict()
    }), 200