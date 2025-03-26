import pytest
from app.MongoClient_async import users_collection
from datetime import datetime, timezone
from app.MongoClient_async import listings_collection
import json
import requests

@pytest.mark.asyncio
async def test_listings_pagination(client, load_payload):
    response = requests.get("http://127.0.0.1:8000/listings")
    assert response.status_code == 200
    data = response.json()
    
    assert len(data["listings"]) == 5
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