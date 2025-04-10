import pytest
from app.MongoClient_async import users_collection
from datetime import datetime, timezone
from app.MongoClient_async import listings_collection
import json
import requests
import os
from bson.objectid import ObjectId
import asyncio


# Helper function to load test payloads
def load_test_payload(filename):
    payload_path = os.path.join(os.path.dirname(__file__), "data", "payloads", filename)
    with open(payload_path, "r") as f:
        return json.load(f)

# Helper function to clean up test users
async def cleanup_test_user(email: str):
    await users_collection.delete_one({"email": email})
    await users_collection.delete_one({"email": "duplicate@mail.utoronto.ca"})

# Helper function to populate an account with necessary fields
async def populate_test_account(email="test_user@mail.utoronto.ca", password="TestPass123!"):
    user_data = {
        "display_name": "Marwan",
        "date_joined": datetime.now(timezone.utc).isoformat(),
        "saved_posts": [],
        "location": "St. George",
        "rating": 4.5,
        "rating_count": 10,
    }
    
    result = await users_collection.insert_one(user_data)
    user_id = str(result.inserted_id)
    
    print(f"Created test account with ID: {user_id}")
    return user_id

@pytest.mark.asyncio
async def test_mongo_modify_user():
    """Test to populate a MongoDB user account with necessary fields"""
    # Create a fully populated test account
    user_id = await populate_test_account()
    return user_id

# Function to modify an existing account with required fields
@pytest.mark.asyncio
async def test_modify_existing_account():
    """Update an existing account with necessary fields"""
    email = "marwan.yousef@utoronto.ca"
    
    # Find the user by email
    user = await users_collection.find_one({"email": email})
    
    if not user:
        print(f"⚠️ User with email {email} not found in database")
        return None
    
    user_id = str(user["_id"])
    
    # Update with necessary fields
    update_data = {
        "$set": {
            "display_name": "Marwan",
            "saved_posts": ["67f3264c01480bf52748c8da"],
            "location": "St. George",
            "rating": 4.5,
            "rating_count": 10
        }
    }
    
    # Apply the update
    result = await users_collection.update_one({"_id": ObjectId(user_id)}, update_data)
    
    if result.modified_count == 1:
        print(f"✅ Successfully updated account with ID: {user_id}")
    else:
        print(f"⚠️ No changes made to account with ID: {user_id}")
    
    # Return the updated user
    updated_user = await users_collection.find_one({"_id": ObjectId(user_id)})
    print(f"Updated user: {updated_user}")
    
    return user_id

@pytest.fixture(scope="session")
def event_loop():
    """Create an instance of the default event loop for each test case."""
    loop = asyncio.get_event_loop_policy().new_event_loop()
    yield loop
    loop.close()

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

# ================================== USER PROFILE TESTS ==================================
@pytest.mark.asyncio
async def test_get_own_profile(client, load_payload):
    # Get test user credentials
    user_payloads = load_test_payload("user.json")
    login_data = user_payloads["valid_login"]
    test_email = login_data["email"]
    
    # First get the user_id by querying the database
    user = await users_collection.find_one({"email": test_email})
    user_id = str(user["_id"])
    
    # Set some profile data
    await users_collection.update_one(
        {"_id": ObjectId(user_id)},
        {"$set": {
            "display_name": "Test User",
            "saved_posts": ["post1", "post2"],
            "rating": 4.5,
            "rating_count": 10
        }}
    )
    
    # Log in to get token
    login_response = requests.post("http://127.0.0.1:8000/login", json=login_data)
    assert login_response.status_code == 200
    token = login_response.json()["access_token"]
    
    # Get own profile
    headers = {"Authorization": f"Bearer {token}"}
    response = requests.get(f"http://127.0.0.1:8000/user/{user_id}", headers=headers)
    
    assert response.status_code == 200
    data = response.json()
    assert data["email"] == test_email
    assert data["display_name"] == "Test User"
    assert "saved_posts" in data
    assert len(data["saved_posts"]) == 2
    assert data["rating"] == 4.5
    assert data["rating_count"] == 10

@pytest.mark.asyncio
async def test_get_other_user_profile(client, load_payload):
    # Get test user credentials
    user_payloads = load_test_payload("user.json")
    login_data = user_payloads["valid_login"]
    test_email = login_data["email"]
    
    other_email = "other@mail.utoronto.ca"
    
    # Get first user's ID from database
    user = await users_collection.find_one({"email": test_email})
    if not user:
        pytest.skip("Test user not found in database")
    user_id = str(user["_id"])
    
    # Create second test user
    other_signup_data = {
        "email": other_email,
        "password": "TestPass123!"
    }
    
    try:
        # Sign up second user
        response = requests.post("http://127.0.0.1:8000/sign-up", json=other_signup_data)
        assert response.status_code == 201
        other_user_id = response.json()["user_id"]
        
        # Set profile data for second user
        await users_collection.update_one(
            {"_id": ObjectId(other_user_id)},
            {"$set": {
                "display_name": "Other User",
                "email": other_email,
                "user_id": other_user_id,
                "rating": 4.0,
                "rating_count": 5,
                "saved_posts": ["secret1", "secret2"]
            }}
        )
        
        # Log in as first user (existing account)
        login_response = requests.post("http://127.0.0.1:8000/login", json=login_data)
        assert login_response.status_code == 200
        token = login_response.json()["access_token"]
        
        # Get other user's profile
        headers = {"Authorization": f"Bearer {token}"}
        response = requests.get(f"http://127.0.0.1:8000/user/{other_user_id}", headers=headers)
        
        assert response.status_code == 200
        data = response.json()
        
        # Test required fields
        assert data["display_name"] == "Other User"
        assert data["email"] == other_email
        assert data["user_id"] == other_user_id
        assert data["rating"] == 4.0
        assert data["rating_count"] == 5
        assert "saved_posts" not in data
        
        # Get own profile
        response = requests.get(f"http://127.0.0.1:8000/user/{user_id}", headers=headers)
        assert response.status_code == 200
        own_data = response.json()
        assert "saved_posts" in own_data
    
    finally:
        # Clean up the second test user
        await cleanup_test_user(other_email)

@pytest.mark.asyncio
async def test_update_user_profile(client, load_payload):
    # Get test user credentials
    user_payloads = load_test_payload("user.json")
    login_data = user_payloads["valid_login"]
    test_email = login_data["email"]
    
    try:
        # Get user from database
        user = await users_collection.find_one({"email": test_email})
        if not user:
            pytest.skip("Test user not found in database")
        user_id = str(user["_id"])
        
        # Log in to get token
        login_response = requests.post("http://127.0.0.1:8000/login", json=login_data)
        assert login_response.status_code == 200
        token = login_response.json()["access_token"]
        
        # Store original values to restore later
        original_values = {
            "display_name": user.get("display_name", "Original Name"),
            "location": user.get("location"),
            "email": user.get("email")
        }
        
        print(user)
        # First ensure user has required fields
        if "display_name" not in user:
            await users_collection.update_one(
                {"_id": ObjectId(user_id)},
                {"$set": {"display_name": "Original Name"}}
            )
        
        # Update profile
        headers = {"Authorization": f"Bearer {token}"}
        update_data = {
            "display_name": "Updated Name",
            "location": "St. George"
        }
        
        response = requests.put(f"http://127.0.0.1:8000/user/{user_id}", headers=headers, json=update_data)
        assert response.status_code == 200
        
        # Verify response format
        response_data = response.json()
        print(response_data)
        assert "display_name" in response_data
        assert "email" in response_data
        assert "user_id" in response_data
        assert response_data["display_name"] == "Updated Name"
        assert response_data["location"] == "St. George"
        
        # Verify update in database
        updated_user = await users_collection.find_one({"_id": ObjectId(user_id)})
        assert updated_user["display_name"] == "Updated Name"
        assert updated_user["location"] == "St. George"
        
    finally:
        # Restore original values
        if 'user_id' in locals() and 'original_values' in locals():
            await users_collection.update_one(
                {"_id": ObjectId(user_id)},
                {"$set": original_values}
            )
