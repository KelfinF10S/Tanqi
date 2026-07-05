from flask import Blueprint, request, jsonify
from flask_jwt_extended import jwt_required, get_jwt_identity
from extensions import db
from models.models import User, Soal, Materi, UserJawaban, UserBab, UserMateri

jawaban_bp = Blueprint("jawaban", __name__)


def _hitung_nilai_bab(user_id: int, bab_id: int):
    """
    Menghitung nilai bab menggunakan attempt terbaru dari setiap materi.
    Return:
        (nilai, total_benar, total_soal)
    """

    semua_materi = Materi.query.filter_by(babid=bab_id).all()

    total_soal = 0
    total_benar = 0

    for materi in semua_materi:

        user_materi = UserMateri.query.filter_by(
            userid=user_id,
            materiid=materi.id
        ).first()

        if not user_materi:
            continue

        latest_attempt = user_materi.attempt

        jawaban = UserJawaban.query.join(
            Soal,
            UserJawaban.soalid == Soal.id
        ).filter(
            UserJawaban.userid == user_id,
            UserJawaban.attempt == latest_attempt,
            Soal.materiid == materi.id
        ).all()

        total_soal += len(jawaban)

        total_benar += sum(
            1 for j in jawaban if j.is_correct
        )

    nilai = 0

    if total_soal > 0:
        nilai = round((total_benar / total_soal) * 100, 1)

    return nilai, total_benar, total_soal

# ──────────────────────────────────────────────
# POST /api/jawaban
# Body: { "soal_id": 1, "jawaban": "B" }
# ──────────────────────────────────────────────
@jawaban_bp.route("/", methods=["POST"])
@jwt_required()
def submit_jawaban():
    user_id = int(get_jwt_identity())
    data = request.get_json()

    soal_id = data.get("soal_id")
    jawaban_user = str(data.get("jawaban", "")).upper().strip()

    if not soal_id or not jawaban_user:
        return jsonify({"message": "soal_id dan jawaban wajib diisi"}), 400

    if jawaban_user not in ("A", "B", "C", "D"):
        return jsonify({"message": "Jawaban harus A, B, C, atau D"}), 400

    soal = Soal.query.get(soal_id)
    if not soal:
        return jsonify({"message": "Soal tidak ditemukan"}), 404

    # Ambil progress materi user (buat baru kalau belum ada)
    user_materi = UserMateri.query.filter_by(
        userid=user_id,
        materiid=soal.materiid
    ).first()

    if not user_materi:
        user_materi = UserMateri(
            userid=user_id,
            materiid=soal.materiid,
            is_completed=False,
            xp_didapat=0,
            attempt=1
        )
        db.session.add(user_materi)
        db.session.commit()

    # Attempt aktif = attempt milik user_materi, langsung dipakai
    current_attempt = user_materi.attempt

    # Cek apakah soal pada attempt ini sudah dijawab
    existing = UserJawaban.query.filter_by(
        userid=user_id,
        soalid=soal_id,
        attempt=current_attempt
    ).first()

    if existing:
        return jsonify({
            "message": "Soal ini sudah dijawab pada attempt ini"
        }), 409

    is_correct = jawaban_user == soal.jawaban_benar.upper()

    # XP hanya pada attempt pertama
    is_attempt_pertama = current_attempt == 1

    xp_didapat = (
        soal.xp_reward
        if is_correct and is_attempt_pertama
        else 0
    )

    new_jawaban = UserJawaban(
        userid=user_id,
        soalid=soal_id,
        jawaban_user=jawaban_user,
        is_correct=is_correct,
        xp_didapat=xp_didapat,
        attempt=current_attempt
    )

    db.session.add(new_jawaban)

    # Tambahkan XP
    if xp_didapat > 0:
        user = User.query.get(user_id)
        user.xp += xp_didapat
        user.level = _hitung_level(user.xp)

    db.session.commit()

    materi_selesai, bab_selesai, nilai = _cek_progress(
        user_id=user_id,
        materi_id=soal.materiid,
        bab_id=soal.babid,
    )

    return jsonify({
        "message": "Jawaban berhasil disimpan",
        "is_correct": is_correct,
        "jawaban_benar": soal.jawaban_benar.upper(),
        "xp_didapat": xp_didapat,
        "materi_selesai": materi_selesai,
        "bab_selesai": bab_selesai,
        "nilai": nilai,
        "data": new_jawaban.to_dict()
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
        userid=user_id,
        materiid=materi_id
    ).first_or_404()

    # Tidak boleh retry kalau attempt sekarang belum selesai
    if not user_materi.is_completed:
        return jsonify({
            "message": "Materi belum selesai dikerjakan"
        }), 400

    # Mulai attempt baru
    user_materi.is_completed = False
    user_materi.attempt += 1

    db.session.commit()

    return jsonify({
        "message": "Materi siap dikerjakan ulang",
        "materiid": materi_id,
        "attempt": user_materi.attempt,   # ← fix: dulu double +1
        "xp_note": "XP hanya diberikan pada attempt pertama"
    }), 200


def _hitung_level(xp: int) -> int:
    if xp < 100:    return 1
    elif xp < 300:  return 2
    elif xp < 600:  return 3
    elif xp < 1000: return 4
    else:           return 5


def _cek_progress(user_id: int, materi_id: int, bab_id: int):
    """
    Mengecek apakah materi selesai, kemudian menghitung progress bab.

    Return:
        (materi_selesai, bab_selesai, nilai)
    """

    user_materi = UserMateri.query.filter_by(
        userid=user_id,
        materiid=materi_id
    ).first()

    if not user_materi:
        return False, False, 0

    current_attempt = user_materi.attempt

    soal_ids = [
        s.id
        for s in Soal.query.filter_by(
            materiid=materi_id
        ).all()
    ]

    total_soal = len(soal_ids)

    if total_soal == 0:
        return False, False, 0

    total_dijawab = UserJawaban.query.filter(
        UserJawaban.userid == user_id,
        UserJawaban.attempt == current_attempt,
        UserJawaban.soalid.in_(soal_ids)
    ).count()

    if total_dijawab < total_soal:
        return False, False, 0

    # ==========================================
    # Materi selesai
    # ==========================================
    if not user_materi.is_completed:

        user_materi.is_completed = True

        xp_attempt_ini = (
            UserJawaban.query.filter(
                UserJawaban.userid == user_id,
                UserJawaban.attempt == current_attempt,
                UserJawaban.soalid.in_(soal_ids)
            )
            .with_entities(db.func.sum(UserJawaban.xp_didapat))
            .scalar()
            or 0
        )

        # xp_didapat hanya diisi kalau ini attempt pertama,
        # supaya histori XP asli tidak ketimpa 0 saat retry
        if current_attempt == 1:
            user_materi.xp_didapat = xp_attempt_ini

    # ==========================================
    # Cek seluruh materi dalam bab
    # ==========================================
    semua_materi = Materi.query.filter_by(
        babid=bab_id
    ).all()

    semua_selesai = True

    for materi in semua_materi:

        um = UserMateri.query.filter_by(
            userid=user_id,
            materiid=materi.id
        ).first()

        if not um or not um.is_completed:
            semua_selesai = False
            break

    if not semua_selesai:
        db.session.commit()
        return True, False, 0

    # ==========================================
    # Hitung nilai bab
    # ==========================================
    nilai, total_benar, total_soal = _hitung_nilai_bab(
        user_id=user_id,
        bab_id=bab_id
    )

    # ==========================================
    # UserBab
    # ==========================================
    user_bab = UserBab.query.filter_by(
        userid=user_id,
        babid=bab_id
    ).first()

    if not user_bab:

        user_bab = UserBab(
            userid=user_id,
            babid=bab_id,
            locked=False,
            is_completed=False,
            nilai=0
        )

        db.session.add(user_bab)

    if nilai > user_bab.nilai:
        user_bab.nilai = nilai

    bab_selesai = user_bab.nilai >= 70

    if bab_selesai and not user_bab.is_completed:

        user_bab.is_completed = True

        bab_berikutnya = UserBab.query.filter_by(
            userid=user_id,
            babid=bab_id + 1
        ).first()

        if bab_berikutnya:
            bab_berikutnya.locked = False

    db.session.commit()

    return (
        True,
        user_bab.is_completed,
        user_bab.nilai
    )