from flask import Blueprint, request, jsonify
from flask_jwt_extended import create_access_token, jwt_required, get_jwt_identity
from werkzeug.security import generate_password_hash, check_password_hash
from extensions import db
from models.models import User, UserBab, UserMateri, Bab, Materi
from config import Config

auth_bp = Blueprint("auth", __name__)

# ──────────────────────────────────────────────
# POST /api/auth/register
# ──────────────────────────────────────────────
@auth_bp.route("/register", methods=["POST"])
def register():
    data = request.get_json()

    username = data.get("username", "").strip()
    password = data.get("password", "").strip()

    role = data.get("role", "murid").strip().lower()
    teacher_token = data.get(
        "teacher_token",
        ""
    ).strip()

    if not username or not password:
        return jsonify({
            "message":
            "Username dan password wajib diisi"
        }), 400

    if len(username) < 3:
        return jsonify({
            "message":
            "Username minimal 3 karakter"
        }), 400

    if role not in ["murid", "guru"]:
        return jsonify({
            "message":
            "Role tidak valid"
        }), 400

    if role == "guru":
        if not teacher_token:
            return jsonify({
                "message":
                "Token guru wajib diisi"
            }), 400

        if teacher_token != Config.GURU_REGISTRATION_KEY :
            return jsonify({
                "message":
                "Token guru tidak valid"
            }), 403

    if User.query.filter_by(
        username=username
    ).first():
        return jsonify({
            "message":
            "Username sudah digunakan"
        }), 409

    new_user = User(
        username=username,
        password=generate_password_hash(
            password
        ),
        role=role,
    )

    db.session.add(new_user)
    db.session.flush()

    # Auto-create UserBab
    for bab in Bab.query.order_by(
        Bab.id
    ).all():
        db.session.add(
            UserBab(
                userid=new_user.id,
                babid=bab.id,
                locked=(bab.id != 1),
            )
        )

    # Auto-create UserMateri
    for materi in Materi.query.all():
        db.session.add(
            UserMateri(
                userid=new_user.id,
                materiid=materi.id,
            )
        )

    db.session.commit()

    return jsonify({
        "message":
        "Registrasi berhasil",

        "user":
        new_user.to_dict()
    }), 201


# ──────────────────────────────────────────────
# POST /api/auth/login
# ──────────────────────────────────────────────
@auth_bp.route("/login", methods=["POST"])
def login():
    data     = request.get_json()
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
# ──────────────────────────────────────────────
@auth_bp.route("/me", methods=["GET"])
@jwt_required()
def me():
    user_id = int(get_jwt_identity())
    user    = User.query.get_or_404(user_id)

    # Hitung bab selesai langsung dari UserBab
    bab_selesai = UserBab.query.filter_by(
        userid=user_id,
        is_completed=True
    ).count()

    user_data              = user.to_dict()
    user_data["bab_selesai"] = bab_selesai

    return jsonify({"user": user_data}), 200


# ──────────────────────────────────────────────
# PUT /api/auth/update-username
# ──────────────────────────────────────────────
@auth_bp.route("/update-username", methods=["PUT"])
@jwt_required()
def update_username():
    user_id = int(get_jwt_identity())
    user    = User.query.get_or_404(user_id)
    data    = request.get_json()

    new_username = data.get("username", "").strip()

    if not new_username:
        return jsonify({"message": "Username wajib diisi"}), 400

    if len(new_username) < 3:
        return jsonify({"message": "Username minimal 3 karakter"}), 400

    if User.query.filter(User.username == new_username, User.id != user_id).first():
        return jsonify({"message": "Username sudah digunakan"}), 409

    user.username = new_username
    db.session.commit()

    return jsonify({
        "message": "Username berhasil diperbarui",
        "user":    user.to_dict()
    }), 200