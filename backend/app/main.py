
import base64
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
    ReviewItem,
    SavedItemsDeleteResponse,
    SavedItemsGetResponse,
    SavedItemsPostRequest,
    SavedItemsPostResponse,
    SearchGetResponse,
    SettingsPutRequest,
    SettingsPutResponse,
    SignUpPostRequest,
    SignUpPostResponse,
    OwnUserGetResponse,
    OtherUserGetResponse,
    UserPutRequest,
    BaseUserResponse,
    ReviewGetResponse,
    ReviewPostRequest,
    ReviewPostResponse
)

from app.MongoClient_async import listings_collection, users_collection, reviews_collection
from dateutil.parser import parse as dateutil_parse
from bson import ObjectId
from pymongo.errors import DuplicateKeyError
from passlib.hash import pbkdf2_sha256
from fastapi.exceptions import RequestValidationError
from fastapi import FastAPI, HTTPException, Query
from fastapi.staticfiles import StaticFiles
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
STATIC_DIR = os.path.join(os.path.dirname(__file__), "static")


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


# @app.exception_handler(RequestValidationError)
# async def validation_exception_handler(request, exc):
#     raise HTTPException(status_code=422, detail="Invalid request.")

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
    price_type: Optional[str] = Query(
        None, description="Type of search (price-high-to-low, price-low-to-high, date-recent)"),
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
        # Default to most recent first
        sort_stage = {"$sort": {"date_posted": -1}}
        if price_type == "price-high-to-low":
            sort_stage = {"$sort": {"price": -1}}
        elif price_type == "price-low-to-high":
            sort_stage = {"$sort": {"price": 1}}
        elif price_type == "date-recent":
            sort_stage = {"$sort": {"date_posted": -1}}

        pipeline = [
            search_stage,
            # Price filter with stable sort using _id as tiebreaker
            {"$sort": {"price": price_order, "_id": 1}
             } if price_order in [-1, 1] else {"$sort": {"_id": 1}},
            # Lower and upper limits of price (0 -> +inf by default)
            {
                "$match": {
                    "price": {"$gte": lower_price, "$lte": upper_price}}} if price_type is not None else None,
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
         response_model=None,
         responses={
             '200': {'model': ListingGetResponseItem},
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
            raise HTTPException(
                status_code=400, details="Invalid listing ID format. Must be a valid Id.")

        # Fetch listing from MongoDB
        pipeline = [
            {
                "$addFields": {
                    "seller_id_as_objid": {"$convert": {"input": "$seller_id", "to": "objectId"}}
                }
            },
            {
                "$match": {
                    "_id": ObjectId(listing_id)
                }
            },
            {
                "$lookup": {
                    "from": "users",
                    "localField": "seller_id_as_objid",
                    "foreignField": "_id",
                    "as": "seller_doc"  # returns an array of docs that match this filter as "seller_doc" field
                }
            },
            {
                # flatten the "seller_doc" field since we expect only one match anyways
                "$unwind": "$seller_doc"
            },
            {
                "$project": {
                    "_id": 1,
                    "title": 1,
                    "price": 1,
                    "description": 1,
                    "seller_id": 1,
                    "pictures": 1,
                    "category": 1,
                    "condition": 1,
                    "campus": 1,
                    "date_posted": 1,
                    "seller_name": "$seller_doc.display_name",
                    "seller_email": "$seller_doc.email",
                }
            }
        ]
        cursor = listings_collection.aggregate(pipeline)
        listing = await cursor.to_list(length=1)

        # Check if listing exists
        if not listing:
            return HTTPException(status_code=404, detail="Listing not found.")

        listing = listing[0]  # take the first document
        # Convert MongoDB document to Pydantic model
        return ListingGetResponseItem(
            id=str(listing["_id"]),
            title=listing.get("title"),
            price=listing.get("price"),
            description=listing.get("description"),
            seller_id=listing.get("seller_id"),
            seller_name=listing.get("seller_name", ""),
            seller_email=listing.get("seller_email", ""),
            pictures=listing.get("pictures", []),
            category=listing.get("category"),
            condition=listing.get("condition"),
            campus=listing.get("campus"),
            date_posted=listing.get("date_posted"),
        )
    except Exception as e:
        raise HTTPException(
            status_code=500, detail="Internal Server Error. Please try again later.")


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
                raise HTTPException(
                    status_code=422, detail="Invalid base64 image format")

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

######################################## SAVED ITEMS ENDPOINTS ###################################


@app.post("/saved_items",
          response_model=SavedItemsPostResponse,
          responses={
              400: {"model": ErrorResponse},
              404: {"model": ErrorResponse},
              409: {"model": ErrorResponse},
              500: {"model": ErrorResponse},
          })
async def save_item(

    body: SavedItemsPostRequest,
    current_user: dict = Depends(get_current_user)
):
    """
    Save an item to the user's saved list.
    """
    try:
        item_id = body.id
        # Validate the ID format
        if not ObjectId.is_valid(item_id):
            raise HTTPException(
                status_code=400, detail="Invalid listing ID format.")

        # Check if the listing exists
        listing = await listings_collection.find_one({"_id": ObjectId(item_id)})
        if not listing:
            raise HTTPException(status_code=404, detail="Listing not found.")

        # Check if the user exists
        user = await users_collection.find_one({"_id": ObjectId(current_user["id"])})
        if not user:
            raise HTTPException(
                status_code=400, detail="User not found. Please log in or sign up.")

        # Check if the item is already saved
        saved_posts = user.get("saved_posts", [])
        if item_id in saved_posts:
            raise HTTPException(status_code=409, detail="Item already saved.")

        if len(saved_posts) >= 30:
            raise HTTPException(
                status_code=400, detail="You can only save up to 30 items.")

        saved_posts.append(item_id)
        await users_collection.update_one({"_id": ObjectId(current_user["id"])}, {"$set": {"saved_posts": saved_posts}})
        return SavedItemsPostResponse(message="Item saved successfully.")

    except HTTPException as e:
        raise e
    except Exception as e:
        raise HTTPException(
            status_code=500, detail=f"Internal Server Error. Please try again later. {e}")


@app.get("/saved_items",
         response_model=SavedItemsGetResponse,
         responses={
             200: {"description": "List of saved listings"},
             400: {"model": ErrorResponse},
             500: {"model": ErrorResponse},
         },
         )
async def get_saved_items(current_user: dict = Depends(get_current_user)):
    try:
        user = await users_collection.find_one({"_id": ObjectId(current_user["id"])})
        if not user:
            raise HTTPException(status_code=400, detail="User not found")

        saved_ids = user.get("saved_posts", [])
        if not saved_ids:
            return [], 0

        # Convert only valid ObjectIds
        object_ids = [ObjectId(item_id)
                      for item_id in saved_ids if ObjectId.is_valid(item_id)]

        listings_cursor = listings_collection.find(
            {"_id": {"$in": object_ids}})
        listings = await listings_cursor.to_list(length=30)

        response_data = [
            ListingGetResponseItem(
                id=str(listing["_id"]),
                title=listing.get("title"),
                price=listing.get("price"),
                description=listing.get("description"),
                seller_id=listing.get("seller_id"),
                pictures=listing.get("pictures", []),
                condition=listing.get("condition"),
                category=listing.get("category"),
                date_posted=listing.get("date_posted"),
                campus=listing.get("campus"),
            )
            for listing in listings
        ]
        return SavedItemsGetResponse(
            saved_items=response_data,
            total=len(response_data),
        )

    except HTTPException as e:
        raise e
    except Exception as e:
        raise HTTPException(
            detail="Internal Server Error. Please try again later.")


@app.delete("/saved_items",
            response_model=SavedItemsDeleteResponse,
            responses={
                400: {"model": ErrorResponse},
                404: {"model": ErrorResponse},
                500: {"model": ErrorResponse},
            })
async def delete_saved_item(saved_item_id: str = Query(..., description="ID of the item to remove"), current_user: dict = Depends(get_current_user)):
    try:
        user = await users_collection.find_one({"_id": ObjectId(current_user["id"])})
        if not user:
            raise HTTPException(status_code=400, detail="User not found")

        saved_posts = user.get("saved_posts", [])
        if saved_item_id not in saved_posts:
            raise HTTPException(
                status_code=404, detail="Item not found in saved list")

        saved_posts.remove(saved_item_id)
        await users_collection.update_one({"_id": ObjectId(current_user["id"])}, {"$set": {"saved_posts": saved_posts}})
        return SavedItemsDeleteResponse(message="Item removed from saved list.")
    except HTTPException as e:
        raise e
    except Exception as e:
        return ErrorResponse(detail="Internal Server Error. Please try again later.")


######################################## USER ENDPOINTS ########################################


@app.get('/user/{userid}',
         response_model=Union[OwnUserGetResponse, OtherUserGetResponse],
         responses={
             '200': {'model': Union[OwnUserGetResponse, OtherUserGetResponse]},
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

        base_response = {
            "display_name": user["display_name"],
            "profile_picture": user.get("profile_picture"),
            "email": user["email"],
            "rating": user.get("rating", 0),
            "user_id": str(user["_id"]),
            "location": user.get("location", ""),
            "rating_count": user.get("rating_count", 0)
        }

        if current_user["id"] == userid:
            return OwnUserGetResponse(**base_response, saved_posts=user.get("saved_posts", []))
        else:
            return OtherUserGetResponse(**base_response)

    except Exception as e:
        raise HTTPException(
            status_code=500, detail=f"Internal Server Error. Please try again later. Error: {str(e)}")


@app.get(
    '/reviews',
    response_model=ReviewGetResponse,
    responses={
        '400': {'model': ErrorResponse},
        '404': {'model': ErrorResponse},
        '500': {'model': ErrorResponse},
    },
    tags=['reviews'],
)
async def get_reviews(seller_id: str) -> Union[ReviewGetResponse, ErrorResponse]:
    """
    Get reviews for a seller
    """
    print("SELLER ID: ", seller_id)
    try:
        reviews_cursor = reviews_collection.find(
            {"seller_id": ObjectId(seller_id)})
        reviews = await reviews_cursor.to_list()

        if not reviews:
            return ReviewGetResponse(
                seller_id=seller_id,
                total_reviews=0,
                average_rating=0.0,
                reviews=[]
            )

        total_reviews = len(reviews)
        average_rating = round(
            sum(r['rating'] for r in reviews)/total_reviews, 2) if total_reviews > 0 else 0.0

        return ReviewGetResponse(
            seller=seller_id,
            total_reviews=total_reviews,
            average_rating=average_rating,
            reviews=[
                ReviewItem(
                    reviewer_id=str(r["reviewer_id"]),
                    rating=r["rating"],
                    comment=r.get("comment"),
                    timestamp=r["timestamp"],
                )
                for r in reviews
            ]
        )

    except Exception as e:
        raise HTTPException(
            status_code=500, detail=f"Internal server Error. {str(e)}")


@app.post(
    '/reviews',
    response_model=ReviewPostResponse,
    responses={
        '201': {'model': ReviewPostResponse},
        '400': {'model': ErrorResponse},
        '404': {'model': ErrorResponse},
        '500': {'model': ErrorResponse},
    },
    tags=['reviews'],
)
async def post_reviews(
    body: ReviewPostRequest,
    current_user: dict = Depends(get_current_user)
) -> Optional[Union[ReviewPostResponse, ErrorResponse]]:
    """
    Create a review for a seller
    """
    try:
        # check if the seller exists
        seller = await users_collection.find_one({"_id": ObjectId(body.seller_id)})
        if not seller:
            raise HTTPException(status_code=404, detail="Seller not found")

        # check if the reviewer has already left a review
        reviews = seller.get("reviews")
        if reviews:
            for review in reviews:
                if current_user["id"] == review.get("reviewer_id"):
                    raise HTTPException(
                        status_code=404, detail="You have already left the user a review")

        review = {
            "seller_id": ObjectId(body.seller_id),
            "reviewer_id": ObjectId(current_user["id"]),
            "rating": body.rating,
            "comment": body.comment,
            "timestamp": datetime.utcnow().isoformat(),
        }

        await reviews_collection.insert_one(review)

        # recalculate average
        current_rating = seller.get("rating", 0.0)
        rating_count = seller.get('rating_count', 0)
        new_avg = round((current_rating * rating_count +
                        body.rating) / (rating_count + 1), 2)

        await users_collection.update_one(
            {"_id": ObjectId(body.seller_id)},
            {"$set": {"rating": new_avg},
             "$inc": {"rating_count": 1}}
        )

        return ReviewPostResponse(message="Review submitted successfully")

    except Exception as e:
        raise HTTPException(
            status_code=500, detail=f"Internal Server Error: {str(e)}")


@app.put('/user/{userid}',
         response_model=None,
         responses={
             '201': {'model': BaseUserResponse},
             '400': {'model': ErrorResponse},
             '403': {'model': ErrorResponse},
             '404': {'model': ErrorResponse},
             '422': {'model': ErrorResponse},
             '500': {'model': ErrorResponse},
         },
         )
async def update_user(userid: str, body: UserPutRequest, current_user: dict = Depends(get_current_user)) -> Union[BaseUserResponse, ErrorResponse]:
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

        return BaseUserResponse(
            display_name=updated_user["display_name"],
            profile_picture=updated_user.get("profile_picture"),
            email=updated_user["email"],
            user_id=str(updated_user["_id"]),
            location=updated_user.get("location", ""),
            rating=updated_user.get("rating", 0.0),
            rating_count=updated_user.get("rating_count", 0),
            saved_posts=updated_user.get("saved_posts", []),
        )

    except Exception as e:
        raise HTTPException(
            status_code=500, detail=f"Internal Server Error. Please try again later {e}")

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
