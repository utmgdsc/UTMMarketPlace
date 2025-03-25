import pytest

def test_signup_success(client, load_payload, load_response):
    payload = load_payload("signup.json")
    expected = load_response("signup_success.json")
    
    response = client.post("/sign-up", json=payload)
    assert response.status_code == 200
    assert response.json()["message"] == expected["message"]
    assert "user_id" in response.json()

# more tests here (same format)