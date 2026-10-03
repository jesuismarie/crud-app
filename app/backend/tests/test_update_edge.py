"""PUT must reject requests that change nothing."""
import pytest


def _make_user(client):
	res = client.post("/api/users", json={
		"first_name": "Ada", "last_name": "Lovelace", "age": 36, "email": "ada@example.com",
	})
	return res.get_json()["id"]


@pytest.mark.parametrize("body", [{"foo": 1}, {"id": 99}, {"unknown": "x", "other": 2}])
def test_put_with_no_known_field_returns_400(client, body):
	user_id = _make_user(client)
	res = client.put(f"/api/users/{user_id}", json=body)
	assert res.status_code == 400
	assert res.get_json()["error"]


def test_put_with_valid_field_still_works(client):
	user_id = _make_user(client)
	res = client.put(f"/api/users/{user_id}", json={"age": 37})
	assert res.status_code == 200
	assert res.get_json()["age"] == 37
