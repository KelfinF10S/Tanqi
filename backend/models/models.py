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

    def to_dict(self):
        return {
            "id":       self.id,
            "username": self.username,
            "xp":       self.xp,
            "level":    self.level,
        }


class Bab(db.Model):
    __tablename__ = 'bab'
    id    = db.Column(db.Integer, primary_key=True)
    judul = db.Column(db.String(100), nullable=False)

    topiks  = db.relationship('Topik', backref='bab', order_by='Topik.urutan') 
    materis = db.relationship('Materi', backref='bab', order_by='Materi.urutan')

    def to_dict(self):
        return {"id": self.id, "judul": self.judul}


class Topik(db.Model):
    __tablename__ = 'topik'
    id     = db.Column(db.Integer, primary_key=True)
    babid  = db.Column(db.Integer, db.ForeignKey('bab.id'), nullable=False)
    judul  = db.Column(db.String(100), nullable=False)
    urutan = db.Column(db.Integer, nullable=False)

    materis = db.relationship('Materi', backref='topik', order_by='Materi.urutan')

    def to_dict(self):
        return {
            "id":     self.id,
            "babid":  self.babid,
            "judul":  self.judul,
            "urutan": self.urutan,
        }


class Materi(db.Model):
    __tablename__ = 'materi'
    id      = db.Column(db.Integer, primary_key=True)
    babid   = db.Column(db.Integer, db.ForeignKey('bab.id'), nullable=False)
    topikid = db.Column(db.Integer, db.ForeignKey('topik.id'), nullable=True)  # ← BARU
    judul   = db.Column(db.String(100), nullable=False)
    urutan  = db.Column(db.Integer, nullable=False)
    slug = db.Column(db.String(50), nullable=True)

    soals = db.relationship('Soal', backref='materi', order_by='Soal.id')

    def to_dict(self):
        return {
            "id":      self.id,
            "babid":   self.babid,
            "topikid": self.topikid,
            "judul":   self.judul,
            "urutan":  self.urutan,
            "slug":   self.slug
        }


class Soal(db.Model):
    __tablename__ = 'soal'
    id            = db.Column(db.Integer, primary_key=True)
    babid         = db.Column(db.Integer, db.ForeignKey('bab.id'), nullable=False)
    materiid      = db.Column(db.Integer, db.ForeignKey('materi.id'), nullable=True)  # ← BARU
    pertanyaan    = db.Column(db.Text, nullable=False)
    pilihan_a     = db.Column(db.String(200))
    pilihan_b     = db.Column(db.String(200))
    pilihan_c     = db.Column(db.String(200))
    pilihan_d     = db.Column(db.String(200))
    jawaban_benar = db.Column(db.String(1), nullable=False)
    xp_reward     = db.Column(db.Integer, default=5)
    penjelasan    = db.Column(db.Text, nullable=True)                                  # ← BARU

    def to_dict(self, hide_answer=False):
        data = {
            "id":         self.id,
            "babid":      self.babid,
            "materiid":   self.materiid,
            "pertanyaan": self.pertanyaan,
            "pilihan_a":  self.pilihan_a,
            "pilihan_b":  self.pilihan_b,
            "pilihan_c":  self.pilihan_c,
            "pilihan_d":  self.pilihan_d,
            "xp_reward":  self.xp_reward,
            "penjelasan": self.penjelasan,
        }
        if not hide_answer:
            data["jawaban_benar"] = self.jawaban_benar
        return data


class UserBab(db.Model):
    __tablename__ = 'user_bab'
    id           = db.Column(db.Integer, primary_key=True)
    userid       = db.Column(db.Integer, db.ForeignKey('user.id'), nullable=False)
    babid        = db.Column(db.Integer, db.ForeignKey('bab.id'), nullable=False)
    locked       = db.Column(db.Boolean, default=True)
    is_completed = db.Column(db.Boolean, default=False)
    nilai        = db.Column(db.Float, default=0)                                      # ← BARU

    def to_dict(self):
        return {
            "id":           self.id,
            "userid":       self.userid,
            "babid":        self.babid,
            "locked":       self.locked,
            "is_completed": self.is_completed,
            "nilai":        self.nilai,
        }


class UserMateri(db.Model):                      # ← BARU
    __tablename__ = 'user_materi'
    id           = db.Column(db.Integer, primary_key=True)
    userid       = db.Column(db.Integer, db.ForeignKey('user.id'), nullable=False)
    materiid     = db.Column(db.Integer, db.ForeignKey('materi.id'), nullable=False)
    is_completed = db.Column(db.Boolean, default=False)
    xp_didapat   = db.Column(db.Integer, default=0)
    attempt      = db.Column(db.Integer, default=0)

    def to_dict(self):
        return {
            "id":           self.id,
            "userid":       self.userid,
            "materiid":     self.materiid,
            "is_completed": self.is_completed,
            "xp_didapat":   self.xp_didapat,
            "attempt":      self.attempt,
        }


class UserJawaban(db.Model):
    __tablename__ = 'user_jawaban'
    id           = db.Column(db.Integer, primary_key=True)
    userid       = db.Column(db.Integer, db.ForeignKey('user.id'), nullable=False)
    soalid       = db.Column(db.Integer, db.ForeignKey('soal.id'), nullable=False)
    jawaban_user = db.Column(db.String(1), nullable=False)
    is_correct   = db.Column(db.Boolean, nullable=False)
    xp_didapat   = db.Column(db.Integer, default=0)
    attempt      = db.Column(db.Integer, default=1)                                    # ← BARU
    created_at   = db.Column(db.DateTime, default=datetime.utcnow)

    def to_dict(self):
        return {
            "id":           self.id,
            "userid":       self.userid,
            "soalid":       self.soalid,
            "jawaban_user": self.jawaban_user,
            "is_correct":   self.is_correct,
            "xp_didapat":   self.xp_didapat,
            "attempt":      self.attempt,
        }