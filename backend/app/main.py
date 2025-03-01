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
    LoginPostRequest,
    LoginPostResponse,
)
from .connect_db import db  # Import MongoDB connection

app = FastAPI(
    title='UTM Marketplace API',
    servers=[
        {'url': 'http://localhost:8000', 'description': 'Local Development Server'},
    ],
)

oauth2_scheme = HTTPBearer()


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


async def authenticate_user(username: str, password: str):
    """
    Check if the user exists and verify the password.
    """
    user = db.users.find_one({"email": username})  # ✅ Async database query

    if not user or not pbkdf2_sha256.verify(password, user["password"]):
        return None
    return user


@app.post('/login', response_model=LoginPostResponse)
async def post_login(body: LoginPostRequest) -> LoginPostResponse:
    """
    Log in an existing user
    """
    user = await authenticate_user(body.username, body.password)

    if not user:
        raise HTTPException(status_code=401, detail="Incorrect email or password")

    token = jwt.encode({"email": user["email"], "id": str(user["_id"])}, JWT_SECRET, algorithm="HS256")
    return LoginPostResponse(access_token=token, token_type="bearer")


@app.get('/listings', response_model=None)
def get_listings() -> None:
    """
    Retrieve all listings
    """
    pass


@app.post('/listings', response_model=None)
def post_listings(body: ListingsPostRequest) -> None:
    """
    Create a new listing
    """
    pass


@app.post(
    '/sign-up', response_model=None, responses={'201': {'model': SignUpPostResponse}}
)
async def post_sign_up(body: SignUpPostRequest) -> Optional[SignUpPostResponse]:
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
