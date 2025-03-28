# generated by fastapi-codegen:
#   filename:  OpenAPI.yaml
#   timestamp: 2025-03-13T13:01:56+00:00

from __future__ import annotations

from datetime import datetime
from typing import List, Optional

from pydantic import BaseModel, EmailStr, Field, SecretStr


class ErrorResponse(BaseModel):
    details: str


class SignUpPostRequest(BaseModel):
    email: EmailStr = Field(
        ...,
        description='Must be a valid University of Toronto email (utoronto.ca or mail.utoronto.ca).',
    )
    password: SecretStr = Field(
        ...,
        description='Must be at least 8 characters, contain 1 uppercase letter, 1 number.',
    )


class LogInPostRequest(BaseModel):
    email: EmailStr = Field(
        ...,
        description='Must be a valid University of Toronto email (utoronto.ca or mail.utoronto.ca).',
    )
    password: SecretStr = Field(
        ...,
        description='Must be at least 8 characters, contain 1 uppercase letter, 1 number.',
    )

class LogInPostResponse(BaseModel):
    access_token: str
    token_type: str

class UserGetResponse(BaseModel):
    display_name: str
    profile_picture: Optional[str]
    email: Optional[str]
    rating: float
    user_id: str
    location: Optional[str]
    rating_count: int
    saved_posts: Optional[List[str]] = None

class UserPutRequest(BaseModel):
    display_name: Optional[str]
    profile_picture: Optional[str]
    email: Optional[EmailStr]
    location: Optional[str]
    rating: Optional[float]
    rating_count: Optional[int]
    saved_posts: Optional[List[str]]

class UserPutResponse(BaseModel):
    display_name: Optional[str]
    profile_picture: Optional[str]
    email: Optional[EmailStr]
    user_id: Optional[str]
    location: Optional[str]


class SignUpPostResponse(BaseModel):
    user_id: str
    message: Optional[str] = None


class SearchGetResponse(BaseModel):
    listings: Optional[List[ListingGetResponseItem]] = None
    total: Optional[int] = None
    next_page_token: Optional[str] = None

class ListingGetResponseItem(BaseModel):
    id: str
    title: str
    price: float
    description: Optional[str] = None
    seller_id: str
    pictures: List[str]
    category: Optional[str] = None
    condition: str
    date_posted: Optional[datetime] = None
    campus: Optional[str] = None


class ListingsGetResponseAll(BaseModel):
    listings: Optional[List[ListingGetResponseItem]] = None
    total: Optional[int] = Field(None, example=10)
    next_page_token: Optional[str] = None


class ListingsPostRequest(BaseModel):
    title: str
    price: float
    description: Optional[str] = None
    seller_id: Optional[str] = None
    pictures: List[str]
    category: Optional[str] = None
    condition: str
    campus: Optional[str] = None


class ListingsPostResponse(BaseModel):
    id: str
    title: Optional[str] = None
    price: Optional[float] = None
    description: Optional[str] = None
    seller_id: Optional[str] = None
    pictures: Optional[List[str]] = None
    category: Optional[str] = None
    condition: Optional[str] = None
    date_posted: Optional[datetime] = None
    campus: Optional[str] = None