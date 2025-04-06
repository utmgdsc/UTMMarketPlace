import pytest
from app.MongoClient_async import users_collection
from datetime import datetime, timezone
from app.MongoClient_async import listings_collection
import json
import requests
import os

# Helper function to load test payloads
def load_test_payload(filename):
    payload_path = os.path.join(os.path.dirname(__file__), "data", "payloads", filename)
    with open(payload_path, "r") as f:
        return json.load(f)

# Helper function to clean up test users
async def cleanup_test_user(email: str):
    await users_collection.delete_one({"email": email})
    await users_collection.delete_one({"email": "duplicate@mail.utoronto.ca"})


# ================================== PAGINATION TESTS ==================================
@pytest.mark.asyncio
async def test_listings_pagination(client, load_payload):
    response = requests.get("http://127.0.0.1:8000/listings")
    assert response.status_code == 200
    data = response.json()
    
    assert len(data["listings"]) == 5
    print(data)
    assert "next_page_token" in data
    
    next_token = data["next_page_token"]
    response = requests.get("http://127.0.0.1:8000/listings", params={"next": next_token})
    assert response.status_code == 200
    data = response.json()
    assert len(data["listings"]) == 5

@pytest.mark.asyncio
async def test_listings_pagination_with_limit(client, load_payload):
    response = requests.get("http://127.0.0.1:8000/listings", params={"limit": 10})
    assert response.status_code == 200
    data = response.json()
    assert len(data["listings"]) == 10
    assert "next_page_token" in data
    
    next_token = data["next_page_token"]
    response = requests.get("http://127.0.0.1:8000/listings", params={"next": next_token, "limit": 10})
    assert response.status_code == 200
    data = response.json()
    assert len(data["listings"]) == 10

# ================================== LOGIN TESTS ==================================
@pytest.mark.asyncio
async def test_login_success(client, load_payload):
    login_payloads = load_test_payload("login_payloads.json")
    login_data = login_payloads["valid_login"]
    
    response = requests.post("http://127.0.0.1:8000/login", json=login_data)
    
    assert response.status_code == 200
    
    data = response.json()
    assert "access_token" in data
    assert "token_type" in data
    assert data["token_type"] == "bearer"
    assert data["access_token"] is not None and data["access_token"] != ""

@pytest.mark.asyncio
async def test_login_incorrect_password_400(client, load_payload):
    login_payloads = load_test_payload("login_payloads.json")
    login_data = login_payloads["incorrect_password"]
    
    response = requests.post("http://127.0.0.1:8000/login", json=login_data)
    
    assert response.status_code == 400
    data = response.json()
    assert "detail" in data
    assert data["detail"] == "Incorrect email or password"

@pytest.mark.asyncio
async def test_login_missing_password_422(client, load_payload):
    login_payloads = load_test_payload("login_payloads.json")
    login_data = login_payloads["missing_password"]
    
    response = requests.post("http://127.0.0.1:8000/login", json=login_data)
    
    assert response.status_code == 422
    data = response.json()
    assert "detail" in data

# ================================== SIGNUP TESTS ==================================
@pytest.mark.asyncio
async def test_signup_success(client, load_payload):
    signup_payloads = load_test_payload("signup_payloads.json")
    signup_data = signup_payloads["valid_signup"]
    test_email = signup_data["email"]
    
    try:
        response = requests.post("http://127.0.0.1:8000/sign-up", json=signup_data)
        
        assert response.status_code == 201
        data = response.json()
        assert "user_id" in data
        assert "message" in data
        assert data["message"] == "User registered successfully."
    finally:
        await cleanup_test_user(test_email)

@pytest.mark.asyncio
async def test_signup_invalid_email_400(client, load_payload):
    signup_payloads = load_test_payload("signup_payloads.json")
    signup_data = signup_payloads["invalid_email"]
    
    response = requests.post("http://127.0.0.1:8000/sign-up", json=signup_data)
    
    assert response.status_code == 400
    data = response.json()
    assert "detail" in data
    assert data["detail"] == "Invalid email format."

@pytest.mark.asyncio
async def test_signup_duplicate_email_409(client, load_payload):
    signup_payloads = load_test_payload("signup_payloads.json")
    signup_data = signup_payloads["duplicate_email"]
    test_email = signup_data["email"]
    
    # First signup
    response = requests.post("http://127.0.0.1:8000/sign-up", json=signup_data)
    assert response.status_code == 201
    
    # Try to signup with same email
    response = requests.post("http://127.0.0.1:8000/sign-up", json=signup_data)
    
    assert response.status_code == 409
    data = response.json()
    assert "detail" in data
    assert data["detail"] == "Email already registered."

@pytest.mark.asyncio
async def test_signup_missing_fields_422(client, load_payload):
    signup_payloads = load_test_payload("signup_payloads.json")
    signup_data = signup_payloads["missing_password"]
    
    response = requests.post("http://127.0.0.1:8000/sign-up", json=signup_data)
    
    assert response.status_code == 422
    data = response.json()
    assert "detail" in data

@pytest.mark.asyncio
async def test_signup_server_error_500(client, load_payload):
    # This test would require mocking the database to simulate a server error
    # For now, we'll just document that this case exists
    pass