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
    assert len(data["listings"]) >= 0

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

# ================================== SEARCH TESTS ==================================
@pytest.fixture
async def setup_search_test_data():
    # Load and insert test data
    test_data = load_test_payload("search_test_data.json")
    await listings_collection.insert_many(test_data["test_listings"])
    
    yield
    
    # Cleanup after tests
    await listings_collection.delete_many({"seller_id": {"$regex": "^test_seller_"}})

@pytest.mark.asyncio
async def test_search_condition_filter(client, setup_search_test_data):
    """Test searching listings with condition filter"""
    # Test condition
    response = requests.get("http://127.0.0.1:8000/search", params={"condition": "Used"})
    assert response.status_code == 200
    data = response.json()
    assert len(data["listings"]) > 0
    assert all(listing["condition"] == "Used" for listing in data["listings"])

@pytest.mark.asyncio
async def test_search_date_range(client, setup_search_test_data):
    """Test searching listings with date range filter"""
    # Test listings after a specific date
    test_date = "2024-03-03T00:00:00Z"
    response = requests.get("http://127.0.0.1:8000/search", params={"date_range": test_date})
    assert response.status_code == 200
    data = response.json()
    assert len(data["listings"]) > 0
    
    # Verify all returned listings are after the test date
    test_datetime = datetime.fromisoformat(test_date.replace('Z', '+00:00'))
    for listing in data["listings"]:
        listing_date = datetime.fromisoformat(listing["date_posted"].replace('Z', '+00:00'))
        assert listing_date >= test_datetime

@pytest.mark.asyncio
async def test_search_condition_and_price_order(client, setup_search_test_data):
    """Test searching listings with condition filter and price ordering"""
    response = requests.get(
        "http://127.0.0.1:8000/search",
        params={
            "condition": "Used",
            "price_type": "price-low-to-high"
        }
    )
    assert response.status_code == 200
    data = response.json()
    assert len(data["listings"]) > 0
    
    # Verify condition and price ordering
    assert all(listing["condition"] == "Used" for listing in data["listings"])
    prices = [listing["price"] for listing in data["listings"]]
    assert prices == sorted(prices)  # Verify prices are in ascending order

@pytest.mark.asyncio
async def test_search_condition_and_price_pagination(client, setup_search_test_data):
    """Test pagination with condition filter and price ordering"""
    # First page
    response = requests.get(
        "http://127.0.0.1:8000/search",
        params={
            "condition": "Used",
            "price_type": "price-low-to-high",
            "limit": 2
        }
    )
    assert response.status_code == 200
    first_page = response.json()
    assert len(first_page["listings"]) == 2
    assert "next_page_token" in first_page
    
    # Second page
    response = requests.get(
        "http://127.0.0.1:8000/search",
        params={
            "condition": "Used",
            "price_type": "price-low-to-high",
            "limit": 2,
            "next": first_page["next_page_token"]
        }
    )
    assert response.status_code == 200
    second_page = response.json()
    assert len(second_page["listings"]) > 0

    all_listings = first_page["listings"] + second_page["listings"]
    
    listing_ids = [listing["id"] for listing in all_listings]
    assert len(listing_ids) == len(set(listing_ids))  # No duplicates
    
    assert all(listing["condition"] == "Used" for listing in all_listings)
    
    prices = [listing["price"] for listing in all_listings]
    assert prices == sorted(prices)

@pytest.mark.asyncio
async def test_search_with_price_range(client, setup_search_test_data):
    """Test searching listings with price range filter"""
    lower_price = 20
    upper_price = 27
    
    response = requests.get(
        "http://127.0.0.1:8000/search",
        params={
            "lower_price": lower_price,
            "upper_price": upper_price,
            "price_type": "price-low-to-high"
        }
    )
    assert response.status_code == 200
    data = response.json()
    assert len(data["listings"]) > 0
    
    # Verify price range
    for listing in data["listings"]:
        assert lower_price <= listing["price"] <= upper_price

@pytest.mark.asyncio
async def test_search_with_campus_filter(client, setup_search_test_data):
    """Test searching listings with campus filter"""
    campus = "St. George"
    
    response = requests.get(
        "http://127.0.0.1:8000/search",
        params={"campus": campus}
    )
    assert response.status_code == 200
    data = response.json()
    assert len(data["listings"]) > 0
    
    # Verify campus filter
    assert all(listing["campus"] == campus for listing in data["listings"])

@pytest.mark.asyncio
async def test_search_with_text_query(client, setup_search_test_data):
    """Test searching listings with text query"""
    query = "test book"
    
    response = requests.get(
        "http://127.0.0.1:8000/search",
        params={"query": query}
    )
    assert response.status_code == 200
    data = response.json()
    assert len(data["listings"]) > 0
    
    for listing in data["listings"]:
        assert (query.lower() in listing["title"].lower() or 
                (listing.get("description") and query.lower() in listing["description"].lower()))
