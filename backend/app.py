from flask import Flask
from config import Config
from extensions import db, jwt

def create_app():
    app = Flask(__name__)
    app.config.from_object(Config)

    db.init_app(app)
    jwt.init_app(app)

    # Register blueprints
    from routes.auth import auth_bp
    from routes.bab import bab_bp
    from routes.jawaban import jawaban_bp
    from routes.profile import profile_bp

    app.register_blueprint(auth_bp,     url_prefix="/api/auth")
    app.register_blueprint(bab_bp,      url_prefix="/api/bab")
    app.register_blueprint(jawaban_bp,  url_prefix="/api/jawaban")
    app.register_blueprint(profile_bp,  url_prefix="/api/profile")

    with app.app_context():
        db.create_all()

    return app


if __name__ == "__main__":
    app = create_app()
    app.run(host='0.0.0.0', port=5000, debug=True)
