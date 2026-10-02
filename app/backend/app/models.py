from . import db


class User(db.Model):
	__tablename__ = "users"

	id = db.Column(db.Integer, primary_key=True)
	first_name = db.Column(db.String(100), nullable=False)
	last_name = db.Column(db.String(100), nullable=False)
	age = db.Column(db.Integer, nullable=False)
	email = db.Column(db.String(150), unique=True, nullable=False)

	def to_dict(self):
		return {
			"id": self.id,
			"first_name": self.first_name,
			"last_name": self.last_name,
			"age": self.age,
			"email": self.email,
		}

	def __repr__(self):
		return f"<User {self.first_name} {self.last_name}>"
