# generated by fastapi-codegen:
#   filename:  OpenAPI.yaml
#   timestamp: 2025-02-16T02:44:10+00:00

from __future__ import annotations
from typing import List, Optional, Union
import re
from fastapi import FastAPI, HTTPException
from passlib.context import CryptContext
from pymongo.errors import DuplicateKeyError

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
    description='API specification for a campus-wide marketplace app',
    version='1.0.0',
    servers=[
        {'url': 'https://api.utmmarketplace.com', 'description': 'Production Server'},
        {'url': 'http://localhost:5000', 'description': 'Local Development Server'},
    ],
)


@app.get('/listings', response_model=List[ListingsGetResponseItem])
def get_listings() -> List[ListingsGetResponseItem]:
    """
    Retrieve all listings
    """
    pass


@app.post(
    '/listings', response_model=None, responses={'201': {'model': ListingsPostResponse}}
)
def post_listings(body: ListingsPostRequest) -> Optional[ListingsPostResponse]:
    """
    Create a new listing
    """
    pass


@app.post(
    '/sign-up',
    response_model=None,
    responses={
        '201': {'model': SignUpPostResponse},
        '400': {'model': SignUpPostResponse1},
        '409': {'model': SignUpPostResponse2},
    },
)
def post_sign_up(body: SignUpPostRequest) -> Optional[Union[SignUpPostResponse, SignUpPostResponse1, SignUpPostResponse2]]:
    """
    Sign up a new user
    """
    email = body.email
    password = body.password.get_secret_value()

    #Validate email
    if not bool(re.match(r"^[a-zA-Z0-9_.+-]+@(utoronto\.ca|mail\.utoronto\.ca)$", email)):
        raise HTTPException(status_code=400, detail="Invalid email format. Please use a UofT email.")
    
    #Hash password
    pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")
    hashed_password = pwd_context.hash(password)

    #Create user document
    user_data = {
        'email': email,
        'password': hashed_password,
    }

    #Send to DB
    try:
        result = db.users.insert_one(user_data)
        return {"user_id": str(result.inserted_id), "message": "User registered successfully."}
    except DuplicateKeyError:
        raise HTTPException(status_code=409, detail="Email already registered.")
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Internal server error: {str(e)}")