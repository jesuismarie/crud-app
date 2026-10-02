import time
from sqlalchemy.exc import OperationalError
from flask import Flask
from flask_sqlalchemy import SQLAlchemy
from flask_cors import CORS

db = SQLAlchemy()


def _init_db(app):
	"""Create tables, retrying while the database is still starting."""
	retries = app.config["DB_CONNECT_RETRIES"]
	for attempt in range(1, retries + 1):
		try:
			db.create_all()
			return
		except OperationalError as exc:
			if attempt == retries:
				raise
			app.logger.warning("Database not ready (%s/%s): %s", attempt, retries, exc.orig)
			time.sleep(app.config["DB_CONNECT_DELAY"])


def create_app(config_class=None):
	if config_class is None:
		from .config import Config
		config_class = Config
	app = Flask(__name__)
	app.config.from_object(config_class)

	CORS(app)
	db.init_app(app)

	from .routes import api_bp
	app.register_blueprint(api_bp)

	with app.app_context():
		_init_db(app)

	return app
