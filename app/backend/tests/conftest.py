"""Shared pytest setup. pytest loads this file automatically."""
import pytest
from app import create_app, db


class TestingConfig:
	"""In-memory SQLite. No MySQL and no .env required."""
	FRONTEND_DIR = None
	TESTING = True
	PROPAGATE_EXCEPTIONS = False
	SQLALCHEMY_DATABASE_URI = "sqlite:///:memory:"
	SQLALCHEMY_TRACK_MODIFICATIONS = False
	SECRET_KEY = "test-only-key"
	DB_CONNECT_RETRIES = 1
	DB_CONNECT_DELAY = 0


@pytest.fixture
def app(tmp_path):
	frontend = tmp_path / "frontend"
	frontend.mkdir()
	(frontend / "index.html").write_text("<h1>test page</h1>")
	(frontend / "app.js").write_text("console.log('test');")
	(tmp_path / "secret.txt").write_text("outside")

	class _Config(TestingConfig):
		FRONTEND_DIR = str(frontend)

	application = create_app(_Config)
	yield application
	with application.app_context():
		db.session.remove()
		db.drop_all()


@pytest.fixture
def client(app):
	return app.test_client()
