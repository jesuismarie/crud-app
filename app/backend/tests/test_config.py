"""config.py reads env at import time — set env, then reload the module."""
import importlib

import pytest

ENV_NAMES = [
	"DATABASE_URL",
	"DB_HOST",
	"DB_PORT",
	"DB_NAME",
	"DB_USER",
	"DB_PASSWORD",
	"SECRET_KEY",
	"DB_CONNECT_RETRIES",
	"DB_CONNECT_DELAY",
]

GOOD_ENV = {
	"DB_HOST": "db",
	"DB_PORT": "3306",
	"DB_NAME": "cruddb",
	"DB_USER": "cruduser",
	"DB_PASSWORD": "s3cret",
	"SECRET_KEY": "test-key",
}


@pytest.fixture
def load_config(monkeypatch):
	monkeypatch.setattr("dotenv.load_dotenv", lambda *args, **kwargs: False)
	for name in ENV_NAMES:
		monkeypatch.delenv(name, raising=False)

	def _load(**env):
		for name, value in env.items():
			monkeypatch.setenv(name, value)
		import app.config as config

		return importlib.reload(config)

	return _load


def test_builds_mysql_uri_from_parts(load_config):
	config = load_config(**GOOD_ENV)
	assert config.Config.SQLALCHEMY_DATABASE_URI == (
		"mysql+pymysql://cruduser:s3cret@db:3306/cruddb"
	)


def test_password_special_characters_are_url_encoded(load_config):
	config = load_config(**{**GOOD_ENV, "DB_PASSWORD": "p@ss:w/rd"})
	uri = config.Config.SQLALCHEMY_DATABASE_URI
	assert "p%40ss%3Aw%2Frd" in uri
	assert "p@ss" not in uri


def test_database_url_overrides_parts(load_config):
	config = load_config(DATABASE_URL="sqlite://", SECRET_KEY="test-key")
	assert config.Config.SQLALCHEMY_DATABASE_URI == "sqlite://"


@pytest.mark.parametrize(
	"missing",
	["DB_HOST", "DB_PORT", "DB_NAME", "DB_USER", "DB_PASSWORD", "SECRET_KEY"],
)
def test_missing_required_env_fails(load_config, missing):
	env = {k: v for k, v in GOOD_ENV.items() if k != missing}
	with pytest.raises(RuntimeError, match=missing):
		load_config(**env)


def test_empty_password_is_missing(load_config):
	with pytest.raises(RuntimeError, match="DB_PASSWORD"):
		load_config(**{**GOOD_ENV, "DB_PASSWORD": ""})


def test_error_does_not_leak_password(load_config):
	with pytest.raises(RuntimeError) as excinfo:
		load_config(**{k: v for k, v in GOOD_ENV.items() if k != "SECRET_KEY"})
	assert "s3cret" not in str(excinfo.value)


def test_retry_settings_have_defaults(load_config):
	config = load_config(**GOOD_ENV)
	assert config.Config.DB_CONNECT_RETRIES >= 1
	assert config.Config.DB_CONNECT_DELAY >= 0
