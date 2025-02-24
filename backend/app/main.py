import jwt
import re
import os
from typing import List, Optional, Union
from fastapi import FastAPI, HTTPException, Depends
from fastapi.security import HTTPBearer
from jwt import decode, exceptions
from passlib.hash import pbkdf2_sha256
from pymongo.errors import DuplicateKeyError
from pydantic import BaseModel
from dotenv import load_dotenv

load_dotenv()  # Load environment variables from .env
JWT_SECRET = os.getenv("JWT_SECRET")

from .models import (
    ListingsGetResponseItem,
    ListingsPostRequest,
    ListingsPostResponse,
    SignUpPostRequest,
    SignUpPostResponse,
    SignUpPostResponse1,
    SignUpPostResponse2,
)
from .connect_db import db  # Import MongoDB connection

app = FastAPI(
    title='UTM Marketplace API',
    servers=[
        {'url': 'http://localhost:8000', 'description': 'Local Development Server'},
    ],
)

oauth2_scheme = HTTPBearer()

### Decode JWT Token (Protect Routes)
async def get_current_user(token: str = Depends(oauth2_scheme)):
    """
    Decode the JWT token and return the user if valid.
    """
    try:
        token = token.credentials  # Extract raw token from HTTPBearer object
        payload = decode(token, JWT_SECRET, algorithms=["HS256"])
        email: str = payload.get("email")
        user_id: str = payload.get("id")

        if email is None or user_id is None:
            raise HTTPException(status_code=401, detail="Invalid token")

        return {"email": email, "id": user_id}

    except exceptions.ExpiredSignatureError:
        raise HTTPException(status_code=401, detail="Token expired")
    except exceptions.DecodeError:
        raise HTTPException(status_code=401, detail="Invalid token")

### User Authentication (Verify Email & Password)
async def authenticate_user(username: str, password: str):
    """
    Check if the user exists and verify the password.
    """
    user = db.users.find_one({"email": username})  # ✅ Async database query

    if not user or not pbkdf2_sha256.verify(password, user["password"]):
        return None
    return user

### Define JWT Token Response
class TokenResponse(BaseModel):
    access_token: str  # Token string
    token_type: str  # Always "bearer"

### Login Request Model (Replaces OAuth2PasswordRequestForm)
class LoginRequest(BaseModel):
    username: str
    password: str

### Generate JWT Token on Successful Login
@app.post('/login', response_model=TokenResponse)
async def login(body: LoginRequest):
    """
    Authenticate user and return a JWT token.
    """
    user = await authenticate_user(body.username, body.password)

    if not user:
        raise HTTPException(status_code=401, detail="Incorrect email or password")

    token = jwt.encode({"email": user["email"], "id": str(user["_id"])}, JWT_SECRET, algorithm="HS256")
    return TokenResponse(access_token=token, token_type="bearer")

### Public Route: Retrieve All Listings (No Authentication Required)
@app.get('/listings', response_model=List[ListingsGetResponseItem])
def get_listings():
    """
    Retrieve all listings (Anyone can view).
    """
    pass

### Protected Route: Create a New Listing (JWT Required)
@app.post('/listings', response_model=ListingsPostResponse)
async def post_listings(
    body: ListingsPostRequest,
    current_user: dict = Depends(get_current_user)  # Require JWT Authentication
):
    """
    Create a new listing (Only authenticated users).
    """
    return {"message": "Listing created!", "created_by": current_user["email"]}

### Public Route: User Registration
@app.post('/sign-up', response_model=Union[SignUpPostResponse, SignUpPostResponse1, SignUpPostResponse2])
async def post_sign_up(body: SignUpPostRequest):
    """
    Sign up a new user.
    """
    email = body.email
    password = body.password.get_secret_value()

    # Validate UofT Email
    if not re.match(r"^[a-zA-Z0-9_.+-]+@(utoronto\.ca|mail\.utoronto\.ca)$", email):
        raise HTTPException(status_code=400, detail="Invalid email format.")

    # Hash password before storing
    hashed_password = pbkdf2_sha256.hash(password)

    # Store User in Database
    try:
        result = await db.users.insert_one({"email": email, "password": hashed_password})
        return {"user_id": str(result.inserted_id), "message": "User registered successfully."}
    except DuplicateKeyError:
        raise HTTPException(status_code=409, detail="Email already registered.")
