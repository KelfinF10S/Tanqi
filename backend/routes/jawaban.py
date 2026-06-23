from flask import Blueprint, request, jsonify
from flask_jwt_extended import jwt_required, get_jwt_identity
from extensions import db
from models.models import User, Soal, Materi, UserJawaban, UserBab, UserMateri

jawaban_bp = Blueprint("jawaban", __name__)


# ──────────────────────────────────────────────
# POST /api/jawaban
# Body: { "soal_id": 1, "jawaban": "B" }
# ──────────────────────────────────────────────
@jawaban_bp.route("/", methods=["POST"])
@jwt_required()
def submit_jawaban():
    user_id = int(get_jwt_identity())
    data    = request.get_json()

    soal_id      = data.get("soal_id")
    jawaban_user = str(data.get("jawaban", "")).upper().strip()

    if not soal_id or not jawaban_user:
        return jsonify({"message": "soal_id dan jawaban wajib diisi"}), 400

    if jawaban_user not in ("A", "B", "C", "D"):
        return jsonify({"message": "Jawaban harus A, B, C, atau D"}), 400

    soal = Soal.query.get(soal_id)
    if not soal:
        return jsonify({"message": "Soal tidak ditemukan"}), 404

    existing = UserJawaban.query.filter_by(userid=user_id, soalid=soal_id).first()
    if existing:
        return jsonify({"message": "Soal ini sudah pernah dijawab"}), 409

    is_correct = jawaban_user == soal.jawaban_benar.upper()

    # XP hanya didapat di attempt pertama materi
    user_materi = UserMateri.query.filter_by(
        userid=user_id, materiid=soal.materiid
    ).first()
    is_attempt_pertama = (user_materi.attempt == 0) if user_materi else True
    xp_didapat = soal.xp_reward if (is_correct and is_attempt_pertama) else 0

    new_jawaban = UserJawaban(
        jawaban_user=jawaban_user,
        is_correct=is_correct,
        xp_didapat=xp_didapat,
        userid=user_id,
        soalid=soal_id,
    )
    db.session.add(new_jawaban)

    # Update XP & level user
    if xp_didapat > 0:
        user       = User.query.get(user_id)
        user.xp   += xp_didapat
        user.level = _hitung_level(user.xp)

    db.session.commit()

    # Cek apakah materi selesai → cek apakah bab selesai
    materi_selesai, bab_selesai, nilai = _cek_progress(user_id, soal.materiid, soal.babid)

    print("materi_selesai =", materi_selesai)
    print("bab_selesai =", bab_selesai)
    print("nilai =", nilai)

    return jsonify({
        "message":        "Jawaban berhasil disimpan",
        "is_correct":     is_correct,
        "jawaban_benar":  soal.jawaban_benar.upper(),
        "xp_didapat":     xp_didapat,
        "materi_selesai": materi_selesai,
        "bab_selesai":    bab_selesai,
        "nilai":          nilai,         # nilai bab (0 kalau belum selesai)
        "data":           new_jawaban.to_dict()
    }), 201


# ──────────────────────────────────────────────
# DELETE /api/jawaban/reset/<materiid>
# Reset jawaban user di satu materi untuk retry
# ──────────────────────────────────────────────
@jawaban_bp.route("/reset/<int:materi_id>", methods=["DELETE"])
@jwt_required()
def reset_jawaban_materi(materi_id):
    user_id = int(get_jwt_identity())

    user_materi = UserMateri.query.filter_by(
        userid=user_id, materiid=materi_id
    ).first_or_404()

    if not user_materi.is_completed:
        return jsonify({"message": "Materi belum selesai dikerjakan"}), 400

    soal_ids = [s.id for s in Soal.query.filter_by(materiid=materi_id).all()]

    UserJawaban.query.filter(
        UserJawaban.userid == user_id,
        UserJawaban.soalid.in_(soal_ids)
    ).delete(synchronize_session="fetch")

    # Reset materi, naikkan attempt
    user_materi.is_completed = False
    user_materi.attempt     += 1

    # Reset is_completed bab juga karena ada materi yang diulang
    materi   = Materi.query.get(materi_id)
    user_bab = UserBab.query.filter_by(
        userid=user_id, babid=materi.babid
    ).first()
    if user_bab:
        user_bab.is_completed = False
        user_bab.nilai        = 0

    db.session.commit()

    return jsonify({
        "message": f"Materi siap dikerjakan ulang",
        "materiid": materi_id,
        "attempt":  user_materi.attempt,
        "xp_note":  "XP tidak akan bertambah pada attempt berikutnya",
    }), 200


def _hitung_level(xp: int) -> int:
    if xp < 100:    return 1
    elif xp < 300:  return 2
    elif xp < 600:  return 3
    elif xp < 1000: return 4
    else:           return 5


def _cek_progress(user_id: int, materi_id: int, bab_id: int):
    """
    Cek apakah materi selesai, lalu cek apakah seluruh bab selesai.
    Return: (materi_selesai, bab_selesai, nilai)
    """
    # ── Cek materi selesai ──
    soal_materi_ids = [s.id for s in Soal.query.filter_by(materiid=materi_id).all()]
    total_materi    = len(soal_materi_ids)

    if total_materi == 0:
        return False, False, 0

    dijawab_materi = UserJawaban.query.filter(
        UserJawaban.userid == user_id,
        UserJawaban.soalid.in_(soal_materi_ids)
    ).count()

    print("materi_id =", materi_id)
    print("total_materi =", total_materi)
    print("dijawab_materi =", dijawab_materi)

    if dijawab_materi < total_materi:
        return False, False, 0  # materi belum selesai

    # Tandai materi selesai
    user_materi = UserMateri.query.filter_by(
        userid=user_id, materiid=materi_id
    ).first()
    if user_materi and not user_materi.is_completed:
        print("MENANDAI MATERI SELESAI")
        user_materi.is_completed = True
        # Catat xp yang didapat di materi ini
        user_materi.xp_didapat = UserJawaban.query.filter(
            UserJawaban.userid == user_id,
            UserJawaban.soalid.in_(soal_materi_ids)
        ).with_entities(db.func.sum(UserJawaban.xp_didapat)).scalar() or 0
        db.session.commit()

    # ── Cek semua materi dalam bab selesai ──
    semua_materi = Materi.query.filter_by(babid=bab_id).all()
    semua_materi_ids = [m.id for m in semua_materi]

    materi_selesai_count = UserMateri.query.filter(
        UserMateri.userid == user_id,
        UserMateri.materiid.in_(semua_materi_ids),
        UserMateri.is_completed == True
    ).count()
    

    if materi_selesai_count < len(semua_materi_ids):
        return True, False, 0  # materi selesai tapi bab belum

    # ── Semua materi selesai → hitung nilai bab ──
    soal_bab_ids = [s.id for s in Soal.query.filter_by(babid=bab_id).all()]
    total_bab    = len(soal_bab_ids)

    total_benar = UserJawaban.query.filter(
        UserJawaban.userid == user_id,
        UserJawaban.soalid.in_(soal_bab_ids),
        UserJawaban.is_correct == True
    ).count()

    nilai = round((total_benar / total_bab) * 100, 1) if total_bab > 0 else 0

    user_bab = UserBab.query.filter_by(
        userid=user_id,
        babid=bab_id
    ).first()

    # kalau belum ada → buat
    if not user_bab:
        user_bab = UserBab(
            userid=user_id,
            babid=bab_id,
            locked=False,
            is_completed=False,
            nilai=0
        )
        db.session.add(user_bab)

    # selalu update nilai
    user_bab.nilai = nilai

    bab_selesai = nilai >= 70

    if bab_selesai:
        user_bab.is_completed = True

        # unlock bab berikutnya
        bab_berikutnya = UserBab.query.filter_by(
            userid=user_id,
            babid=bab_id + 1
        ).first()

        if bab_berikutnya:
            bab_berikutnya.locked = False

    db.session.commit()

    print("========== BAB CHECK ==========")
    print("nilai =", nilai)
    print("bab_selesai =", bab_selesai)
    print("user_bab.nilai =", user_bab.nilai)
    print("user_bab.is_completed =", user_bab.is_completed)
    print("==============================")

    return True, bab_selesai, nilai