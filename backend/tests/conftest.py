import pytest
from fastapi.testclient import TestClient
import sys
import os
import json
from pathlib import Path

# Add the parent directory to Python path
sys.path.append(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

from app.main import app

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