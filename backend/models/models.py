from extensions import db
from datetime import datetime


class User(db.Model):
    __tablename__ = "user"

    id         = db.Column(db.Integer,      primary_key=True, autoincrement=True)
    username   = db.Column(db.String(255),  nullable=False, unique=True)
    password   = db.Column(db.String(1000), nullable=False)
    created_at = db.Column(db.DateTime,     default=datetime.utcnow)
    xp         = db.Column(db.Integer,      default=0)
    level      = db.Column(db.SmallInteger, default=1)

    jawaban    = db.relationship("UserJawaban", backref="user", lazy=True)

    def to_dict(self):
        return {
            "id":         self.id,
            "username":   self.username,
            "xp":         self.xp,
            "level":      self.level,
            "created_at": self.created_at.isoformat(),
        }


class Bab(db.Model):
    __tablename__ = "bab"

    id     = db.Column(db.Integer,     primary_key=True, autoincrement=True)
    judul  = db.Column(db.String(255), nullable=False)
    locked = db.Column(db.Boolean,     default=True)

    soal   = db.relationship("Soal", backref="bab", lazy=True)

    def to_dict(self):
        return {
            "id":     self.id,
            "judul":  self.judul,
            "locked": self.locked,
        }


class Soal(db.Model):
    __tablename__ = "soal"

    id            = db.Column(db.Integer,     primary_key=True, autoincrement=True)
    pertanyaan    = db.Column(db.String(255), nullable=False)
    opsi_a        = db.Column(db.String(255), nullable=False)
    opsi_b        = db.Column(db.String(255), nullable=False)
    opsi_c        = db.Column(db.String(255), nullable=False)
    opsi_d        = db.Column(db.String(255), nullable=False)
    jawaban_benar = db.Column(db.String(1),   nullable=False)
    xp_reward     = db.Column(db.Integer,     default=0)
    babid         = db.Column(db.Integer,     db.ForeignKey("bab.id"), nullable=False)

    def to_dict(self, hide_answer=True):
        data = {
            "id":         self.id,
            "pertanyaan": self.pertanyaan,
            "opsi_a":     self.opsi_a,
            "opsi_b":     self.opsi_b,
            "opsi_c":     self.opsi_c,
            "opsi_d":     self.opsi_d,
            "xp_reward":  self.xp_reward,
            "babid":      self.babid,
        }
        if not hide_answer:
            data["jawaban_benar"] = self.jawaban_benar
        return data


class UserJawaban(db.Model):
    __tablename__ = "user_jawaban"

    id           = db.Column(db.Integer,    primary_key=True, autoincrement=True)
    jawaban_user = db.Column(db.String(1),  nullable=False)
    is_correct   = db.Column(db.Boolean,    default=False)
    xp_didapat   = db.Column(db.Integer,    default=0)
    anwsered_at  = db.Column(db.DateTime,   default=datetime.utcnow)
    userid       = db.Column(db.Integer,    db.ForeignKey("user.id"), nullable=False)
    soalid       = db.Column(db.Integer,    db.ForeignKey("soal.id"), nullable=False)

    soal         = db.relationship("Soal", backref="jawaban_list", lazy=True)

    def to_dict(self):
        return {
            "id":           self.id,
            "jawaban_user": self.jawaban_user,
            "is_correct":   self.is_correct,
            "xp_didapat":   self.xp_didapat,
            "anwsered_at":  self.anwsered_at.isoformat(),
            "userid":       self.userid,
            "soalid":       self.soalid,
        }
