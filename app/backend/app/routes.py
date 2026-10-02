import re

from flask import Blueprint, request, jsonify
from sqlalchemy import text
from sqlalchemy.exc import IntegrityError, SQLAlchemyError
from werkzeug.exceptions import HTTPException

from . import db
from .models import User

api_bp = Blueprint("api", __name__, url_prefix="/api")

EMAIL_RE = re.compile(r"^[^@\s]+@[^@\s]+\.[^@\s]+$")
TEXT_FIELDS = {"first_name": 100, "last_name": 100, "email": 150}


def _clean_user(data, partial=False):
	"""Return (values, error). Exactly one of them is None.
	partial=True (PUT): fields may be missing, but those present are checked."""
	if not isinstance(data, dict):
		return None, "Body must be a JSON object"

	values = {}
	for field, max_len in TEXT_FIELDS.items():
		if field not in data:
			if partial:
				continue
			return None, f"Missing required field: {field}"
		value = data[field]
		if not isinstance(value, str):
			return None, f"{field} must be a string"
		value = value.strip()
		if not value or len(value) > max_len:
			return None, f"{field} must be 1-{max_len} characters"
		values[field] = value

	if "email" in values:
		values["email"] = values["email"].lower()
		if not EMAIL_RE.match(values["email"]):
			return None, "Email must be a valid email address"

	if "age" in data:
		age = data["age"]
		if not isinstance(age, int) or isinstance(age, bool):
			return None, "age must be an integer"
		if age < 0 or age > 150:
			return None, "Age must be between 0 and 150"
		values["age"] = age
	elif not partial:
		return None, "Missing required field: age"

	return values, None


@api_bp.route("/ready", methods=["GET"])
def ready():
	"""Readiness: can we reach the database?"""
	try:
		db.session.execute(text("SELECT 1"))
	except SQLAlchemyError:
		db.session.rollback()
		return jsonify({"status": "not ready"}), 503
	return jsonify({"status": "ready"}), 200


@api_bp.route("/health", methods=["GET"])
def health():
	"""Health check endpoint"""
	return jsonify({"status": "healthy"}), 200


@api_bp.app_errorhandler(HTTPException)
def handle_http_error(e):
	return jsonify({"error": e.name}), e.code


@api_bp.app_errorhandler(500)
def handle_internal_error(e):
	db.session.rollback()
	return jsonify({"error": "Internal server error"}), 500


@api_bp.route("/users", methods=["GET"])
def get_users():
	"""Read all users"""
	users = User.query.order_by(User.id).all()
	return jsonify([user.to_dict() for user in users]), 200


@api_bp.route("/users/<int:user_id>", methods=["GET"])
def get_user(user_id):
	"""Read a single user"""
	user = db.get_or_404(User, user_id)
	return jsonify(user.to_dict()), 200


@api_bp.route("/users", methods=["POST"])
def create_user():
	"""Create a new user"""
	data = request.get_json(silent=True)

	if not data:
		return jsonify({"error": "No data provided"}), 400

	values, error = _clean_user(data)
	if error:
		return jsonify({"error": error}), 400

	if User.query.filter_by(email=values["email"]).first():
		return jsonify({"error": "Email already exists"}), 409

	user = User(**values)
	db.session.add(user)
	try:
		db.session.commit()
	except IntegrityError:
		db.session.rollback()
		return jsonify({"error": "Email already exists"}), 409

	return jsonify(user.to_dict()), 201


@api_bp.route("/users/<int:user_id>", methods=["PUT"])
def update_user(user_id):
	"""Update an existing user"""
	user = db.get_or_404(User, user_id)
	data = request.get_json(silent=True)

	if not data:
		return jsonify({"error": "No data provided"}), 400

	values, error = _clean_user(data, partial=True)
	if error:
		return jsonify({"error": error}), 400

	if "email" in values:
		existing = User.query.filter_by(email=values["email"]).first()
		if existing and existing.id != user.id:
			return jsonify({"error": "Email already exists"}), 409

	for field, value in values.items():
		setattr(user, field, value)

	try:
		db.session.commit()
	except IntegrityError:
		db.session.rollback()
		return jsonify({"error": "Email already exists"}), 409

	return jsonify(user.to_dict()), 200


@api_bp.route("/users/<int:user_id>", methods=["DELETE"])
def delete_user(user_id):
	"""Delete a user"""
	user = db.get_or_404(User, user_id)
	db.session.delete(user)
	db.session.commit()
	return jsonify({"message": f"User {user_id} deleted successfully"}), 200
