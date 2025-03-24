import pytest
from app.MongoClient_async import users_collection
from datetime import datetime, timezone
from app.MongoClient_async import listings_collection
import json

# @pytest.fixture(autouse=True)
# async def cleanup_test_user():
#     await users_collection.delete_many({"email": "marwan@utoronto.ca"})
#     yield
#     await users_collection.delete_many({"email": "marwan@utoronto.ca"})

@pytest.fixture(autouse=True)
@pytest.mark.asyncio
async def cleanup_test_listings():
    await listings_collection.delete_many({})
    yield
    await listings_collection.delete_many({})

# def test_signup_success(client, load_payload, load_response):
#     payload = load_payload("signup.json")
#     expected = load_response("signup_success.json")
    
#     response = client.post("/sign-up", json=payload)
#     assert response.status_code == 201
#     assert response.json()["message"] == expected["message"]
#     assert "user_id" in response.json()

@pytest.mark.asyncio
async def create_test_listings(load_payload):
    base_listing = load_payload("listings.json")["listings"][0]
    listings = []
    
    # Create 10 listings with different titles
    for i in range(10):  # Changed from 5 to 10 to test pagination
        listing = base_listing.copy()
        listing["title"] = f"Test Listing {i+1}"
        listing["price"] = 100 + i
        listing["date_posted"] = datetime.now(timezone.utc).isoformat()
        listing["seller_id"] = "test_seller"
        listings.append(listing)
    
    # Insert all listings
    await listings_collection.insert_many(listings)

@pytest.mark.asyncio
async def test_listings_pagination(client, load_payload):
    # First, create test listings
    await create_test_listings(load_payload)
    
    # Test first page
    response = client.get("/listings")
    assert response.status_code == 200
    data = response.json()
    
    # Check first page structure
    assert len(data["listings"]) == 5
    assert "next_page_token" in data
    first_page_ids = {listing["id"] for listing in data["listings"]}
    
    next_token = data["next_page_token"]
    
    # Get second page
    response = client.get(f"/listings?next={next_token}")
    assert response.status_code == 200
    data = response.json()
    
    # Check second page
    assert len(data["listings"]) == 5  # Should get next 5 items
    second_page_ids = {listing["id"] for listing in data["listings"]}
    
    # Verify no duplicate listings between pages
    assert not first_page_ids.intersection(second_page_ids)
    
    # Test with custom limit
    response = client.get("/listings?limit=10")
    assert response.status_code == 200
    data = response.json()
    assert len(data["listings"]) == 10
    
    # Test with invalid limit (should be capped to 30)
    response = client.get("/listings?limit=50")
    assert response.status_code == 200
    data = response.json()
    assert len(data["listings"]) <= 30
    
    