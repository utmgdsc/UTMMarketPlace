# Testing Guide

## Overview
This project uses `pytest` for testing API endpoints. Each test verifies the expected behavior by comparing actual responses with predefined expected results stored in JSON files.

## Ensure you run requirements.txt

## Adding a New Test
To add a new test:

1. **Create a Payload JSON File**: Define the request payload in `tests/payloads/your_test_name.json`.
2. **Create an Expected Response JSON File**: Define the expected response in `tests/responses/your_test_name.json`.
3. **Write the Test Function**:
    - Use the `client` fixture to make a request.
    - Load the payload and expected response using `load_payload` and `load_response`.
    - Assert the response status and expected values.

### Example:

**1. Create `tests/payloads/login.json`**
```json
{
  "username": "testuser",
  "password": "securepassword"
}
```

**2. Create `tests/responses/login_success.json`**
```json
{
  "message": "Login successful",
  "token": "some_jwt_token"
}
```

**3. Add a test function in `test_endpoints.py`**
```python
import pytest

def test_login_success(client, load_payload, load_response):
    payload = load_payload("login.json")
    expected = load_response("login_success.json")
    
    response = client.post("/login", json=payload)
    
    assert response.status_code == 200
    assert response.json()["message"] == expected["message"]
    assert "token" in response.json()
```

## Running Tests
Ensure the FastAPI server is running.

Run all tests with:
```sh
pytest -v
```

Run a specific test:
```sh
pytest -v test_endpoints.py::test_login_success
```

Run tests and stop on first failure:
```sh
pytest -v -x
```

Run tests with detailed output:
```sh
pytest -v --tb=long
```

Run tests with no warnings:
```sh
pytest -v --disable-warnings
```