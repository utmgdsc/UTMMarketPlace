from draftAPP.models import ErrorResponse, LogInPostRequest, LogInPostResponse
import jwt
import re
import os
from typing import List, Optional, Union
from fastapi import FastAPI, HTTPException, Depends
from fastapi.security import HTTPBearer
from jwt import decode, exceptions
from pydantic import BaseModel, ValidationError
from dotenv import load_dotenv
from fastapi.responses import JSONResponse
from fastapi.requests import Request

load_dotenv()  # Load environment variables from .env
JWT_SECRET = os.getenv("JWT_SECRET")
from datetime import datetime
from fastapi.exceptions import RequestValidationError
from passlib.hash import pbkdf2_sha256
from pymongo.errors import DuplicateKeyError, PyMongoError
from bson import ObjectId

#importing async way of connecting to MongoDB
from MongoClient_async import db, listings_collection

from models import (
    Field500ErrorResponse,
    ListingGetResponse,
    ListingGetResponse1,
    ListingsGetAllResponse,
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
    description='API specification for a campus-wide marketplace app',
    version='1.0.0',
    servers=[
        {'url': 'https://api.utmmarketplace.com', 'description': 'Production Server'},
        {'url': 'http://localhost:5000', 'description': 'Local Development Server'},
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
    except HTTPException as exc:
        raise exc
    except Exception:
        raise HTTPException(status_code=500, detail="An unexpected error occurred.")
  
@app.exception_handler(RequestValidationError)
async def validation_exception_handler(request, exc):
    raise HTTPException(status_code=422, detail="Invalid request data body")

@app.get(
    '/listing/{listing_id}',
    response_model=ListingsGetResponseItem,
    responses={
        '400': {'model': ListingGetResponse},
        '404': {'model': ListingGetResponse1},
        '500': {'model': Field500ErrorResponse},
    },
)
async def get_listing(
    listing_id: str,
) -> Union[
    ListingsGetResponseItem, ListingGetResponse, ListingGetResponse1, Field500ErrorResponse]:
    """
    Retrieve a single listing by ID
    """
    try:
        # Validate ObjectId
        if not ObjectId.is_valid(listing_id):
            return ListingGetResponse(error="Invalid listing ID format. Must be a valid Id.")

        # Fetch listing from MongoDB
        listing = await listings_collection.find_one({"_id": ObjectId(listing_id)})

        # Check if listing exists
        if not listing:
            return ListingGetResponse1(error="Listing not found.")

        # Convert MongoDB document to Pydantic model
        return ListingsGetResponseItem(
            id=str(listing.get("_id"),
            title=listing.get("title"),
            price=listing.get("price"),
            description=listing.get("description"),
            seller_id=listing.get("seller_id"),
            pictures=listing.get("pictures", []),
            category=listing.get("category"),
            date_posted=listing.get("date_posted"),
            campus=listing.get("campus"),
        )
        )
    except Exception as e:
        return Field500ErrorResponse(error="Internal Server Error. Please try again later.")

          
@app.get('/listings', 
    response_model=ListingsGetAllResponse, responses={'500': {'model': Field500ErrorResponse}},)
async def get_listings() -> Union[ListingsGetAllResponse, Field500ErrorResponse]:
    try:
        # Fetch all listings from MongoDB
        cursor = listings_collection.find()
        listings = await cursor.to_list(length=None)  # Get all documents
        response_data = []
        for listing in listings:
            try:
                response_data.append(
                    ListingsGetResponseItem(
                        id=str(listing.get("_id")),
                        title=listing.get("title"),
                        price=listing.get("price"),
                        description=listing.get("description"),
                        seller_id=listing.get("seller_id"),
                        pictures=listing.get("pictures", []),
                        condition=listing.get("condition"),
                        category=listing.get("category"),
                        date_posted=listing.get("date_posted"),  # need to decide on the date format
                        campus=listing.get("campus"),
                    )
                )
            except Exception as e:
                print(f"Skipping invalid listing {listing['_id']}: {e}")  # i kept this for later and we can potentially use it for logging 

        return ListingsGetAllResponse(listings=response_data, total=len(response_data))

    except Exception as e:
        return Field500ErrorResponse(error="Internal Server Error. Please try again later.")

async def authenticate_user(username: str, password: str):
    """
    Check if the user exists and verify the password.
    """
    user = db.users.find_one({"email": username})

    if not user or not pbkdf2_sha256.verify(password, user["password"]):
        return None
    return user


@app.post(
    '/login',
    response_model=LogInPostResponse,
    responses={
        '200': {'model': LogInPostResponse},
        '400': {'model': ErrorResponse}, 
        '422': {'model': ErrorResponse}},
)
async def post_login(body: LogInPostRequest) -> Union[LogInPostResponse, ErrorResponse]:
    """
    Log in an existing user
    """
    user = await authenticate_user(body.username, body.password)

    if not user:
        raise HTTPException(status_code=400, detail="Incorrect email or password")

    token = jwt.encode({"email": user["email"], "id": str(user["_id"])}, JWT_SECRET, algorithm="HS256")
    return LoginPostResponse(access_token=token, token_type="bearer")


@app.post(
    '/listings',
    response_model=None,
    responses={
        '201': {'model': ListingsPostResponse},
        '500': {'model': Field500ErrorResponse},
    },
)
async def post_listings(
    body: ListingsPostRequest,
) -> Optional[Union[ListingsPostResponse, Field500ErrorResponse]]:
    """
    Create a new listing
    """
    try:
        # Prepare data for MongoDB
        listing_data = body.dict()
        listing_data["date_posted"] = datetime.utcnow().isoformat()  # Ensure date is handled properly

        # Insert into MongoDB
        result = await listings_collection.insert_one(listing_data)

        # Return the created listing
        return ListingsPostResponse(
            id=str(result.inserted_id),
            title=body.title,
            price=body.price,
            description=body.description,
            seller_id=body.seller_id,
            pictures=body.pictures,
            category=body.category,
            date_posted=listing_data["date_posted"],
            condition=body.condition,
            campus=body.campus,
        )
    except ValidationError as e:
        return Field500ErrorResponse(error="Validation error. Please check your input data.")
    except Exception as e:
        return Field500ErrorResponse(error="Internal Server Error. Please try again later.")

@app.post(
    '/sign-up',
    response_model=None,
    responses={
        '201': {'model': SignUpPostResponse},
        '400': {'model': ErrorResponse},
        '409': {'model': ErrorResponse},
        '422': {'model': ErrorResponse},
        '500': {'model': ErrorResponse},
    },
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
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Internal server error: {str(e)}")