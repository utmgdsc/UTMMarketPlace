from fastapi.staticfiles import StaticFiles
import jwt
from jwt import decode, exceptions
import re
import os
from typing import List, Optional, Union
from fastapi import FastAPI, HTTPException, Depends
from fastapi.security import HTTPBearer
from pydantic import BaseModel, ValidationError
from dotenv import load_dotenv
from fastapi.responses import JSONResponse
from fastapi.requests import Request
import base64
import json
load_dotenv()  # Load environment variables from .env
JWT_SECRET = os.getenv("JWT_SECRET")
STATIC_DIR = os.getenv("STATIC_DIR", "static")
from datetime import datetime, timezone, timedelta
from fastapi import FastAPI, HTTPException, Query, Header
from fastapi.exceptions import RequestValidationError
from passlib.hash import pbkdf2_sha256
from pymongo.errors import DuplicateKeyError, PyMongoError
from bson import ObjectId
from dateutil.parser import parse as dateutil_parse

#importing async way of connecting to MongoDB
from app.MongoClient_async import db, listings_collection, users_collection


from app.models import (
    ConversationsGetResponse,
    ErrorResponse,
    ListingGetResponseItem,
    ListingsGetResponseAll,
    ListingsPostRequest,
    ListingsPostResponse,
    LogInPostRequest,
    LogInPostResponse,
    MessagesGetResponse,
    MessagesPostRequest,
    MessagesPostResponse,
    SavedItemsDeleteResponse,
    SavedItemsGetResponse,
    SavedItemsPostRequest,
    SavedItemsPostResponse,
    SearchGetResponse,
    SettingsPutRequest,
    SettingsPutResponse,
    SignUpPostRequest,
    SignUpPostResponse,
    UserGetResponse,
    UserPutRequest,
)
from app.MongoClient_async import listings_collection, users_collection
from dateutil.parser import parse as dateutil_parse
from bson import ObjectId
from pymongo.errors import DuplicateKeyError
from passlib.hash import pbkdf2_sha256
from fastapi.exceptions import RequestValidationError
from fastapi import FastAPI, HTTPException, Query
from datetime import datetime, timezone, timedelta
import jwt
from jwt import decode, exceptions
import re
import os
from typing import Optional, Union
from fastapi import FastAPI, HTTPException, Depends
from fastapi.security import HTTPBearer
from pydantic import ValidationError
from dotenv import load_dotenv
from fastapi.responses import JSONResponse
load_dotenv()  # Load environment variables from .env
JWT_SECRET = os.getenv("JWT_SECRET")


app = FastAPI(
    title='UTM Marketplace API',
    description='API specification for a campus-wide marketplace app',
    version='1.0.0',
    servers=[
        {'url': 'https://api.utmmarketplace.com',
            'description': 'Production Server'},
        {'url': 'http://localhost:5000', 'description': 'Local Development Server'},
    ],
)

app.mount("/static", StaticFiles(directory=STATIC_DIR), name="static")

oauth2_scheme = HTTPBearer()

######################################## HELPER METHODS ########################################


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
        raise HTTPException(
            status_code=500, detail="An unexpected error occurred.")


async def authenticate_user(email: str, password):
    """
    Check if the user exists and verify the password.
    """
    user = await users_collection.find_one({"email": email})

    if not user:
        # print("no user") # debugging purposes
        return None
    elif not pbkdf2_sha256.verify(password.get_secret_value(), user["password"]):
        # print("wrong pass")
        return None
    return user


@app.exception_handler(RequestValidationError)
async def validation_exception_handler(request, exc):
    raise HTTPException(status_code=422, detail="Invalid request.")

######################################## LISTINGS ENDPOINTS ########################################


@app.get(
    '/search',
    response_model=SearchGetResponse,
    responses={'500': {'model': ErrorResponse}},
)
async def get_search(
    # Used in for full text search
    query: Optional[str] = Query(None, description="query"),
    limit: Optional[int] = Query(
        5, description="Number of listings to retrieve", ge=1, le=30),
    next: Optional[str] = Query(
        None, description="Last seen pagination token"),
    price_type: Optional[str] = Query(None, description="Type of search (price-high-to-low, price-low-to-high, date-recent)"),
    lower_price: Optional[int] = Query(
        0, description="lower end of price filter"),
    upper_price: Optional[int] = Query(
        int(10**9), description="upper end of price filter"),
    condition: Optional[str] = Query(
        None, description="Filters such as condition, price, FILL IN"),
    date_range: Optional[str] = Query(
        None, description="Lower end of date filter"),
    campus: Optional[str] = Query(
        None, description="Campus location of listings")
) -> Union[SearchGetResponse, ErrorResponse]:
    """
    search listings
    """
    price_order = 0
    limit = min(max(limit, 1), 30)
    try:
        if query:
            # Full text search
            search_stage = {
                "$search": {
                    "index": "Full_text_index_listings",
                    "text": {
                        "query": query,
                        "path": {
                            "wildcard": "*",
                        },
                    },
                },
            }
        else:
            search_stage = {"$search": {
                "index": "Full_text_index_listings",
                # This is always true; essentially just gets all documents
                "exists": {"path": "_id"},
            }}

        if next:
            search_stage["$search"]["searchAfter"] = next

        # Selecting which order to sort by
        sort_stage = {"$sort": {"date_posted": -1}}  # Default to most recent first
        if price_type == "price-high-to-low":
            sort_stage = {"$sort": {"price": -1}}
        elif price_type == "price-low-to-high":
            sort_stage = {"$sort": {"price": 1}}
        elif price_type == "date-recent":
            sort_stage = {"$sort": {"date_posted": -1}}

        pipeline = [
            search_stage,
            # Lower and upper limits of price (0 -> +inf by default)
            {
                "$match": {
                    "price": {"$gte": lower_price, "$lte": upper_price}}} if price_type is not None else None,
            # Sort by price or date (always included since we have a default)
            sort_stage,
            # Condition filter
            {
                "$match": {
                    "condition": condition}} if condition else None,
            # Date filter
            {
                "$match": {
                    "date_posted": {"$gte": dateutil_parse(date_range).isoformat()}}}
                if date_range is not None else None,
            {
                "$match": {
                    "campus": campus}} if campus else None,
            {"$limit": limit},
            {"$project": {
                "id": {"$toString": "$_id"},
                "title": 1,
                "price": 1,
                "description": 1,
                "seller_id": 1,
                "pictures": 1,
                "condition": 1,
                "category": 1,
                "date_posted": 1,
                "campus": 1,
                # Provide pagination tokens generated by Atlas Search
                #   so that clients can provide this on next query
                "paginationToken": {"$meta": "searchSequenceToken"},
            }}
        ]

        # Clean the pipeline of any None values
        pipeline = [stage for stage in pipeline if stage is not None]

        cursor = listings_collection.aggregate(pipeline)
        listings = await cursor.to_list(length=limit)

        # Prepping to return
        response_data = [
            ListingGetResponseItem(
                id=str(listing["_id"]),
                title=listing["title"],
                price=listing["price"],
                description=listing.get("description"),
                seller_id=listing["seller_id"],
                pictures=listing.get("pictures", []),
                condition=listing["condition"],
                category=listing.get("category"),
                date_posted=listing.get("date_posted"),
                campus=listing.get("campus"),
            )
            for listing in listings
        ]

        if not response_data:
            return SearchGetResponse(listings=[],
                                     total=0,
                                     next_page_token=None)

        listings = ListingsGetResponseAll(
            listings=response_data,
            total=len(response_data),
            next_page_token=listings[-1].get("paginationToken")
        )

        return SearchGetResponse(listings=listings.listings,
                                 total=listings.total,
                                 next_page_token=listings.next_page_token)
    except Exception as e:
        print(f"Error: {str(e)}")
        return ErrorResponse(details="Internal Server Error. Please try again later.")


@app.get('/listing/{listing_id}',
         response_model=ListingGetResponseItem,
         responses={
             '400': {'model': ErrorResponse},
             '404': {'model': ErrorResponse},
             '422': {'model': ErrorResponse},
             '500': {'model': ErrorResponse},
         },
         )
async def get_listing(listing_id: str) -> Union[ListingGetResponseItem, ErrorResponse]:
    """
    Retrieve a single listing by ID
    """
    try:
        # Validate ObjectId
        if not ObjectId.is_valid(listing_id):
            return ListingGetResponseItem(error="Invalid listing ID format. Must be a valid Id.")

        # Fetch listing from MongoDB
        listing = await listings_collection.find_one({"_id": ObjectId(listing_id)})

        # Check if listing exists
        if not listing:
            return HTTPException(status_code=404, detail="Listing not found.")

        # Convert MongoDB document to Pydantic model

        return ListingGetResponseItem(
            id=str(listing.get("_id")),
            title=listing.get("title"),
            price=listing.get("price"),
            description=listing.get("description"),
            seller_id=listing.get("seller_id"),
            pictures=listing.get("pictures", []),
            category=listing.get("category"),
            date_posted=listing.get("date_posted"),
            campus=listing.get("campus"),
        )
    except Exception as e:
        return ErrorResponse(status_code=500, details="Internal Server Error. Please try again later.")


@app.get('/listings',
         response_model=ListingsGetResponseAll,
         responses={'500': {'model': ErrorResponse}},
         )
async def get_listings(
    query: Optional[str] = Query(None, description="query"),
    limit: Optional[int] = Query(
        5, description="Number of listings to retrieve", ge=1, le=30),
    next: Optional[str] = Query(
        None, description="Last seen pagination token"),
) -> Union[ListingsGetResponseAll, ErrorResponse]:
    """
    Retrieve listings using cursor-based pagination.
    """
    try:
        limit = min(max(limit, 1), 30)  # Ensure limit stays between 1 and 30

        if query:
            print("GOT Query", query)
            search_stage = {
                "$search": {
                    "index": "Full_text_index_listings",
                    "text": {
                        "query": query,
                        "path": {
                            "wildcard": "*",
                        },
                    },
                },
            }
        else:
            print("NO QUERY")
            search_stage = {
                "$search": {
                    "index": "Full_text_index_listings",
                    # This is always true; essentially just gets all documents
                    "exists": {"path": "_id"},
                }
            }

        if next:
            search_stage["$search"]["searchAfter"] = next
            # print(f"Using next token: {next}")  # Debugging: Check next token value

        pipeline = [
            search_stage,
            {"$limit": limit},
            {"$project": {
                "id": {"$toString": "$_id"},
                "title": 1,
                "price": 1,
                "description": 1,
                "seller_id": 1,
                "pictures": 1,
                "condition": 1,
                "category": 1,
                "date_posted": 1,
                "campus": 1,
                # Provide pagination tokens generated by Atlas Search
                #   so that clients can provide this on next query
                "paginationToken": {"$meta": "searchSequenceToken"},
            }}
        ]

        # Execute query
        cursor = listings_collection.aggregate(pipeline)
        listings = await cursor.to_list(length=limit)

        if not listings:
            return ListingsGetResponseAll(listings=[], total=0, next_page_token=None)

        # Convert documents to Pydantic models
        response_data = [
            ListingGetResponseItem(
                id=str(listing["_id"]),
                title=listing["title"],
                price=listing["price"],
                description=listing.get("description"),
                seller_id=listing["seller_id"],
                pictures=listing.get("pictures", []),
                condition=listing["condition"],
                category=listing.get("category"),
                date_posted=listing.get("date_posted"),
                campus=listing.get("campus"),
            )
            for listing in listings
        ]

        return ListingsGetResponseAll(
            listings=response_data,
            total=len(response_data),
            # Provide the last token of this page, so that clients
            #  can use this to get the next page
            next_page_token=listings[-1].get("paginationToken"),
        )
    except Exception as e:
        return ErrorResponse(details="Internal Server Error. Please try again later.")



@app.post(
    '/listings',
    response_model=None,
    status_code=201,
    responses={
        '201': {'model': ListingsPostResponse},
        '401': {'model': ErrorResponse},
        '422': {'model': ErrorResponse},
        '500': {'model': ErrorResponse},
    },
)
async def post_listings(
    body: ListingsPostRequest, current_user: dict = Depends(get_current_user)
) -> Optional[Union[ListingsPostResponse, ErrorResponse]]:
    """
    Create a new listing
    """
    try:

        # Prepare data for MongoDB
        listing_data = body.dict()
        listing_data["date_posted"] = datetime.now(
            timezone.utc).isoformat()  # Ensure date is handled properly
        listing_data["seller_id"] = current_user["id"]

        # Insert into MongoDB
        result = await listings_collection.insert_one(listing_data)

        image_urls = []

        os.makedirs(STATIC_DIR, exist_ok=True)

        for idx, image_b64 in enumerate(body.pictures):
            if image_b64.startswith("data:image"):
                image_b64 = image_b64.split(",")[1]

            try:
                img_data = base64.b64decode(image_b64)
            except Exception:
                raise HTTPException(status_code=422, detail="Invalid base64 image format")
        
            filename = f"{result.inserted_id}_{idx}.jpg"
            filepath = os.path.join(STATIC_DIR, filename)

            with open(filepath, "wb") as f:
                f.write(img_data)
            
            image_urls.append(f"/static/{filename}")

        await listings_collection.update_one(
            {"_id": result.inserted_id},
            {"$set": {"pictures": image_urls}}
        )

        # Return the created listing
        return ListingsPostResponse(
            id=str(result.inserted_id),
            title=body.title,
            price=body.price,
            description=body.description,
            seller_id=current_user["id"],
            pictures=image_urls,
            category=body.category,
            date_posted=listing_data["date_posted"],
            condition=body.condition,
            campus=body.campus,
        )
    
    except exceptions.ExpiredSignatureError:
        raise HTTPException(
            status_code=401, detail="Token expired, login again")
    except ValidationError as e:
        return ErrorResponse(status_code=422, details="Validation error. Please check your input data.")
    except Exception as e:
        return ErrorResponse(status_code=500, details="Internal Server Error. Please try again later.")

######################################## USER ENDPOINTS ########################################


@app.get('/user/{userid}',
         response_model=UserGetResponse,
         responses={
             '200': {'model': UserGetResponse},
             '400': {'model': ErrorResponse},
             '404': {'model': ErrorResponse},
             '422': {'model': ErrorResponse},
             '500': {'model': ErrorResponse},
         },)
async def get_user(userid: str, current_user: dict = Depends(get_current_user)):
    """Retrieve user details, hide saved_posts if not the same user."""
    try:
        user = await users_collection.find_one({"_id": ObjectId(userid)})
        if not user:
            raise HTTPException(status_code=404, detail="User not found")

        response = {
            "display_name": user["display_name"],
            "profile_picture": user.get("profile_picture"),
            "email": user["email"],
            "rating": user.get("rating", 0),
            "user_id": str(user["_id"]),
            "location": user.get("location", ""),
            "rating_count": user.get("rating_count", 0)
        }

        if current_user["id"] == userid:
            response["saved_posts"] = user.get("saved_posts", [])

        return UserGetResponse(**response)
    except Exception as e:
        raise HTTPException(
            status_code=500, detail=f"Internal Server Error. Please try again later. Error: {str(e)}")


@app.put('/user/{userid}',
         response_model=None,
         responses={
             '201': {'model': UserGetResponse},
             '400': {'model': ErrorResponse},
             '403': {'model': ErrorResponse},
             '404': {'model': ErrorResponse},
             '422': {'model': ErrorResponse},
             '500': {'model': ErrorResponse},
         },
         )
async def update_user(userid: str, body: UserPutRequest, current_user: dict = Depends(get_current_user)) -> Union[UserGetResponse, ErrorResponse]:
    """
    Update user details only if the user matches.
    """
    try:
        # Check if the user matches the user being updated
        if current_user["id"] != userid:
            raise HTTPException(
                status_code=403, detail="Unauthorized to update this user")

        user = await users_collection.find_one({"_id": ObjectId(userid)})
        if not user:
            raise HTTPException(status_code=404, detail="User not found")

        update_data = body.dict(exclude_unset=True)

        # checking if email is valid format
        if "email" in update_data:
            if not re.match(r"^[a-zA-Z0-9_.+-]+@(utoronto\.ca|mail\.utoronto\.ca)$", update_data["email"]):
                raise HTTPException(
                    status_code=400, detail="Invalid email format.")

        await users_collection.update_one({"_id": ObjectId(userid)}, {"$set": update_data})

        updated_user = await users_collection.find_one({"_id": ObjectId(userid)})

        return UserGetResponse(
            display_name=updated_user["display_name"],
            profile_picture=updated_user.get("profile_picture"),
            email=updated_user["email"],
            user_id=str(updated_user["_id"]),
            location=updated_user.get("location", ""),
        )

    except Exception as e:
        raise HTTPException(
            status_code=500, detail=f"Internal Server Error. Please try again later")

######################################## LOGIN/SIGNUP ENDPOINTS ########################################


@app.post('/login',
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
    # Extract the string value from the SecretStr object

    user = await authenticate_user(body.email, body.password)

    if not user:
        raise HTTPException(
            status_code=400, detail="Incorrect email or password")

    expiration = datetime.now(timezone.utc) + timedelta(hours=1)

    token = jwt.encode(
        {
            "email": user["email"],
            "id": str(user["_id"]),
            "exp": expiration
        },
        JWT_SECRET,
        algorithm="HS256"
    )
    return LogInPostResponse(access_token=token, token_type="bearer")


@app.post('/sign-up',
          response_model=None,
          responses={
              '201': {'model': SignUpPostResponse},
              '400': {'model': ErrorResponse},
              '409': {'model': ErrorResponse},
              '422': {'model': ErrorResponse},
              '500': {'model': ErrorResponse},
          },
          )
async def post_sign_up(
    body: SignUpPostRequest,
) -> Optional[Union[SignUpPostResponse, ErrorResponse]]:
    """
    Sign up a new user.
    """
    email = body.email.lower()
    password = body.password.get_secret_value()

    # Validate UofT Email
    if not re.match(r"^[a-zA-Z0-9_.+-]+@(utoronto\.ca|mail\.utoronto\.ca)$", email):
        raise HTTPException(status_code=400, detail="Invalid email format.")
    if await users_collection.find_one({"email": email}):
        raise HTTPException(
            status_code=409, detail="Email already registered.")

    # Hash password before storing
    hashed_password = pbkdf2_sha256.hash(password)

    # Store User in Database
    try:
        result = await users_collection.insert_one({"email": email, "password": hashed_password})
        return JSONResponse(
            status_code=201,
            content={"user_id": str(result.inserted_id), "message": "User registered successfully."})
    except DuplicateKeyError:
        raise HTTPException(
            status_code=409, detail="Email already registered.")
    except Exception as e:
        raise HTTPException(
            status_code=500, detail=f"Internal server error: {str(e)}")

######################################## SAVED ITEMS ########################################


@app.post(
    '/saved_items',
    response_model=None,
    responses={
        '201': {'model': SavedItemsPostResponse},
        '422': {'model': ErrorResponse},
        '500': {'model': ErrorResponse},
    },
)
def post_saved_items(
    body: SavedItemsPostRequest,
) -> Optional[Union[SavedItemsPostResponse, ErrorResponse]]:
    """
    Save a listing to a users saved posts. This endpoint requires authentication.
    """
    pass


@app.get(
    '/saved_items',
    response_model=SavedItemsGetResponse,
    responses={
        '400': {'model': ErrorResponse},
        '404': {'model': ErrorResponse},
        '500': {'model': ErrorResponse},
    },
)
def get_saved_items() -> Union[SavedItemsGetResponse, ErrorResponse]:
    """
    Retrieve saved items for a user. User id is determined based on JWT.
    """
    pass


@app.delete(
    '/saved_items',
    response_model=SavedItemsDeleteResponse,
    responses={
        '400': {'model': ErrorResponse},
        '404': {'model': ErrorResponse},
        '500': {'model': ErrorResponse},
    },
)
def delete_saved_items(
    saved_item_id: str,
) -> Union[SavedItemsDeleteResponse, ErrorResponse]:
    """
    Delete a saved item
    """
    pass


######################################## MESSAGES ########################################
@app.get(
    '/conversations',
    response_model=ConversationsGetResponse,
    responses={
        '400': {'model': ErrorResponse},
        '422': {'model': ErrorResponse},
        '500': {'model': ErrorResponse},
    },
)
def get_conversations(user_id: str) -> Union[ConversationsGetResponse, ErrorResponse]:
    """
    Retrieve user conversations
    """
    pass


@app.post(
    '/messages',
    response_model=None,
    responses={
        '201': {'model': MessagesPostResponse},
        '422': {'model': ErrorResponse},
        '500': {'model': ErrorResponse},
    },
)
def post_messages(
    body: MessagesPostRequest,
) -> Optional[Union[MessagesPostResponse, ErrorResponse]]:
    """
    Send a message
    """
    pass


@app.get(
    '/messages',
    response_model=MessagesGetResponse,
    responses={
        '400': {'model': ErrorResponse},
        '404': {'model': ErrorResponse},
        '500': {'model': ErrorResponse},
    },
)
def get_messages(
    user1: str, user2: str = ...
) -> Union[MessagesGetResponse, ErrorResponse]:
    """
    Retrieve messages between two users
    """
    pass


######################################## SETTINGS ########################################
@app.put(
    '/settings',
    response_model=SettingsPutResponse,
    responses={
        '422': {'model': ErrorResponse},
        '404': {'model': ErrorResponse},
        '500': {'model': ErrorResponse},
    },
)
def put_settings(body: SettingsPutRequest) -> Union[SettingsPutResponse, ErrorResponse]:
    """
    Update user settings
    """
    pass
