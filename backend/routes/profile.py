from flask import Blueprint, jsonify
from flask_jwt_extended import jwt_required, get_jwt_identity
from models.models import User, UserJawaban, Soal, Bab, db # Pastikan db diimport
from sqlalchemy import func

profile_bp = Blueprint("profile", __name__)

@profile_bp.route("/", methods=["GET"])
@jwt_required()
def get_profile():
    user_id = get_jwt_identity()
    user    = User.query.get_or_404(user_id)

    total_soal_per_bab = db.session.query(
        Soal.babid, 
        func.count(Soal.id).label('total')
    ).group_by(Soal.babid).all()
    
    soal_user_dijawab = db.session.query(
        Soal.babid, 
        func.count(UserJawaban.id).label('dijawab')
    ).join(UserJawaban, Soal.id == UserJawaban.soalid)\
     .filter(UserJawaban.userid == user_id)\
     .group_by(Soal.babid).all()

    # Ubah hasil query ke dictionary agar mudah dibandingkan
    dict_total = {b: t for b, t in total_soal_per_bab}
    dict_user  = {b: d for b, d in soal_user_dijawab}

    # Hitung berapa banyak bab yang 'dijawab == total'
    bab_selesai_count = 0
    for bab_id, total in dict_total.items():
        if bab_id in dict_user:
            if dict_user[bab_id] >= total: # Jika soal dijawab sudah sama atau lebih (antisipasi double)
                bab_selesai_count += 1


    # HITUNG STATISTIK
    semua_jawaban  = UserJawaban.query.filter_by(userid=user_id).all()
    total_dijawab  = len(semua_jawaban)
    total_benar    = sum(1 for j in semua_jawaban if j.is_correct)
    total_salah    = total_dijawab - total_benar
    total_xp       = sum(j.xp_didapat for j in semua_jawaban)

    akurasi = round((total_benar / total_dijawab * 100), 1) if total_dijawab > 0 else 0.0

    # RIWAYAT
    riwayat = (
        UserJawaban.query
        .filter_by(userid=user_id)
        .order_by(UserJawaban.anwsered_at.desc())
        .limit(10)
        .all()
    )

    # GABUNGKAN DATA
    user_data = user.to_dict()
    user_data['bab_selesai'] = bab_selesai_count

    return jsonify({
        "user": user_data,
        "statistik": {
            "total_soal_dijawab": total_dijawab,
            "total_benar":        total_benar,
            "total_salah":        total_salah,
            "total_xp":           total_xp,
            "akurasi_persen":     akurasi,
        },
        "riwayat_jawaban": [j.to_dict() for j in riwayat]
    }), 200