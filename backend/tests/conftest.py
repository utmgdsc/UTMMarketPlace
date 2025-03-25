import pytest
from fastapi.testclient import TestClient
import json
from pathlib import Path

from app.main import app  # This will now work directly once app/ has __init__.py

@pytest.fixture
def client():
    return TestClient(app)

@pytest.fixture
def test_data_dir():
    return Path(__file__).parent / "data"

@pytest.fixture
def load_payload():
    def _load_payload(filename):
        filepath = Path(__file__).parent / "data" / "payloads" / filename
        with open(filepath, "r") as f:
            return json.load(f)
    return _load_payload

@pytest.fixture
def load_response():
    def _load_response(filename):
        filepath = Path(__file__).parent / "data" / "responses" / filename
        with open(filepath, "r") as f:
            return json.load(f)
    return _load_response