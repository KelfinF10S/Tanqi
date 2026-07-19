# models/models.py

from extensions import db
from datetime import datetime


class User(db.Model):
    __tablename__ = 'user'
    id       = db.Column(db.Integer, primary_key=True)
    username = db.Column(db.String(80), unique=True, nullable=False)
    password = db.Column(db.String(200), nullable=False)
    xp       = db.Column(db.Integer, default=0)
    level    = db.Column(db.Integer, default=1)
    role     = db.Column(db.String(20), nullable=False, default='murid')

    def to_dict(self):
        return {
            "id":       self.id,
            "username": self.username,
            "xp":       self.xp,
            "level":    self.level,
            "role":     self.role,
        }


class Bab(db.Model):
    __tablename__ = 'bab'
    id    = db.Column(db.Integer, primary_key=True)
    judul = db.Column(db.String(100), nullable=False)

    kuis = db.relationship('Kuis', backref='bab', uselist=False)  # 1:1

    def to_dict(self):
        return {"id": self.id, "judul": self.judul}


# class Topik(db.Model):
#     __tablename__ = 'topik'
#     id     = db.Column(db.Integer, primary_key=True)
#     babid  = db.Column(db.Integer, db.ForeignKey('bab.id'), nullable=False)
#     judul  = db.Column(db.String(100), nullable=False)
#     urutan = db.Column(db.Integer, nullable=False)

#     materis = db.relationship('Materi', backref='topik', order_by='Materi.urutan')

#     def to_dict(self):
#         return {
#             "id":     self.id,
#             "babid":  self.babid,
#             "judul":  self.judul,
#             "urutan": self.urutan,
#         }


# class Materi(db.Model):
#     __tablename__ = 'materi'
#     id      = db.Column(db.Integer, primary_key=True)
#     babid   = db.Column(db.Integer, db.ForeignKey('bab.id'), nullable=False)
#     judul   = db.Column(db.String(100), nullable=False)
#     urutan  = db.Column(db.Integer, nullable=False)
#     slug    = db.Column(db.String(50), nullable=True)

#     def to_dict(self):
#         return {
#             "id":      self.id,
#             "babid":   self.babid,
#             "judul":   self.judul,
#             "urutan":  self.urutan,
#             "slug":    self.slug,
#         }


class UserBab(db.Model):
    __tablename__ = 'user_bab'
    id     = db.Column(db.Integer, primary_key=True)
    userid = db.Column(db.Integer, db.ForeignKey('user.id'), nullable=False)
    babid  = db.Column(db.Integer, db.ForeignKey('bab.id'), nullable=False)
    locked = db.Column(db.Boolean, default=True)
    # is_completed & nilai dipindah ke UserKuis (1 bab = 1 kuis)

    def to_dict(self):
        return {
            "id":     self.id,
            "userid": self.userid,
            "babid":  self.babid,
            "locked": self.locked,
        }


class UserMateri(db.Model):
    __tablename__ = 'user_materi'
    id           = db.Column(db.Integer, primary_key=True)
    userid       = db.Column(db.Integer, db.ForeignKey('user.id'), nullable=False)
    materiid     = db.Column(db.Integer, db.ForeignKey('materi.id'), nullable=False)
    is_completed = db.Column(db.Boolean, default=False)
    # attempt & xp_didapat dihapus - materi tidak lagi punya kuis

    def to_dict(self):
        return {
            "id":           self.id,
            "userid":       self.userid,
            "materiid":     self.materiid,
            "is_completed": self.is_completed,
        }


class Kuis(db.Model):
    __tablename__ = 'kuis'
    id            = db.Column(db.Integer, primary_key=True)
    babid         = db.Column(db.Integer, db.ForeignKey('bab.id'), nullable=False, unique=True)
    judul         = db.Column(db.String(100), default='Kuis')
    passing_score = db.Column(db.Float, default=70)
    xp_per_soal = db.Column(db.Integer, nullable=False, default=10) 

    soal_list = db.relationship('SoalKuis', backref='kuis', order_by='SoalKuis.urutan', cascade='all, delete-orphan')

    def to_dict(self):
        return {
            "id":            self.id,
            "babid":         self.babid,
            "judul":         self.judul,
            "passing_score": self.passing_score,
        }


class SoalKuis(db.Model):
    __tablename__ = 'soal_kuis'
    id            = db.Column(db.Integer, primary_key=True)
    kuisid        = db.Column(db.Integer, db.ForeignKey('kuis.id'), nullable=False)
    tipe          = db.Column(db.Enum('multiple_choice', 'drag_drop', 'tap_object', name='tipe_soal_kuis'), nullable=False)
    urutan        = db.Column(db.Integer, nullable=False)
    pertanyaan    = db.Column(db.String(255), nullable=False)
    konten        = db.Column(db.JSON, nullable=False)
    jawaban_benar = db.Column(db.JSON, nullable=False)
    penjelasan    = db.Column(db.Text, nullable=True)

    def to_dict(self, hide_answer=False):
        data = {
            "id":         self.id,
            "kuisid":     self.kuisid,
            "tipe":       self.tipe,
            "urutan":     self.urutan,
            "pertanyaan": self.pertanyaan,
            "konten":     self.konten,
            "penjelasan": self.penjelasan,
        }
        if not hide_answer:
            data["jawaban_benar"] = self.jawaban_benar
        return data


class UserKuis(db.Model):
    __tablename__ = 'user_kuis'
    id           = db.Column(db.Integer, primary_key=True)
    userid       = db.Column(db.Integer, db.ForeignKey('user.id'), nullable=False)
    kuisid       = db.Column(db.Integer, db.ForeignKey('kuis.id'), nullable=False)
    attempt      = db.Column(db.Integer, default=1)
    is_completed = db.Column(db.Boolean, default=False)
    nilai        = db.Column(db.Float, default=0)

    __table_args__ = (
        db.UniqueConstraint('userid', 'kuisid', name='unique_user_kuis'),
    )

    def to_dict(self):
        return {
            "id":           self.id,
            "userid":       self.userid,
            "kuisid":       self.kuisid,
            "attempt":      self.attempt,
            "is_completed": self.is_completed,
            "nilai":        self.nilai,
        }


class UserJawabanKuis(db.Model):
    __tablename__ = 'user_jawaban_kuis'
    id           = db.Column(db.Integer, primary_key=True)
    userid       = db.Column(db.Integer, db.ForeignKey('user.id'), nullable=False)
    soal_kuisid  = db.Column(db.Integer, db.ForeignKey('soal_kuis.id'), nullable=False)
    jawaban_user = db.Column(db.JSON, nullable=False)
    is_correct   = db.Column(db.Boolean, nullable=False, default=False)
    attempt      = db.Column(db.Integer, default=1)
    created_at   = db.Column(db.DateTime, default=datetime.utcnow)

    def to_dict(self):
        return {
            "id":           self.id,
            "userid":       self.userid,
            "soal_kuisid":  self.soal_kuisid,
            "jawaban_user": self.jawaban_user,
            "is_correct":   self.is_correct,
            "attempt":      self.attempt,
        }