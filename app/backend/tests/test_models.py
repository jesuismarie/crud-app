from app.models import User


def test_to_dict_contains_all_fields():
	user = User(id=1, first_name="Ada", last_name="Lovelace", age=36, email="ada@example.com")
	assert user.to_dict() == {
		"id": 1,
		"first_name": "Ada",
		"last_name": "Lovelace",
		"age": 36,
		"email": "ada@example.com",
	}


def test_repr_includes_name():
	user = User(first_name="Ada", last_name="Lovelace", age=36, email="ada@example.com")
	assert "Ada" in repr(user)
	assert "Lovelace" in repr(user)
