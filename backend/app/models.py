# generated by fastapi-codegen:
#   filename:  OpenAPI.yaml

from __future__ import annotations

from datetime import datetime
from typing import List, Optional

from pydantic import BaseModel, EmailStr, Field, SecretStr, confloat
class BaseUserResponse(BaseModel):
    display_name: str
    profile_picture: Optional[str] = None
    email: Optional[EmailStr] = None
    user_id: str
    location: Optional[str] = None
    rating: float
    rating_count: int
    reviews: Optional[List[ReviewItem]] = None

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


class SignUpPostResponse(BaseModel):
    user_id: str
    message: Optional[str] = None


class ListingGetResponseItem(BaseModel):
    id: str
    title: str
    price: float
    description: Optional[str] = None
    seller_id: str
    seller_name: Optional[str] = None
    seller_email: Optional[str] = None
    pictures: List[str]
    category: Optional[str] = None
    condition: str
    date_posted: Optional[datetime] = None
    campus: Optional[str] = None


class ListingsGetResponseAll(BaseModel):
    listings: Optional[List[ListingGetResponseItem]] = None
    total: Optional[int] = None
    next_page_token: Optional[str] = None


class ListingsPostRequest(BaseModel):
    title: str
    price: float
    description: Optional[str] = None
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


class MessagesPostRequest(BaseModel):
    sender_id: str = Field(
        ..., description='The unique identifier of the user sending the message.'
    )
    recipient_id: str = Field(
        ..., description='The unique identifier of the user receiving the message.'
    )
    content: str = Field(..., description='The content of the message.')


class MessagesPostResponse(BaseModel):
    message_id: str = Field(
        ..., description='The unique identifier of the created message.'
    )
    message: str = Field(..., description='Confirmation message.')
    timestamp: datetime = Field(..., description='The time when the message was sent.')


class MessageGetResponseItem(BaseModel):
    message_id: str = Field(..., description='Unique identifier for the message.')
    sender_id: str = Field(
        ..., description='Identifier for the user who sent the message.'
    )
    recipient_id: str = Field(
        ..., description='Identifier for the user who received the message.'
    )
    content: str = Field(..., description='The content of the message.')
    timestamp: datetime = Field(..., description='The time when the message was sent.')


class SettingsPutRequest(BaseModel):
    notifications: Optional[bool] = Field(
        None, description='Flag indicating whether notifications are enabled.'
    )
    theme: Optional[str] = Field(
        None, description='The UI theme preference (e.g., "light" or "dark").'
    )
    text_size: Optional[int] = Field(None, description='The preferred text font size.')


class SettingsPutResponse(BaseModel):
    notifications: Optional[bool] = Field(
        None, description='Current notification setting.'
    )
    theme: Optional[str] = Field(None, description='Current UI theme preference.')
    text_size: Optional[int] = Field(None, description='Current text size setting.')


class OwnUserGetResponse(BaseUserResponse):
    saved_posts: Optional[List[str]] = None


class OtherUserGetResponse(BaseUserResponse):
    pass


class UserPutRequest(BaseModel):
    display_name: Optional[str] = None
    profile_picture: Optional[str] = None
    email: Optional[EmailStr] = None
    location: Optional[str] = None


class SavedItemsPostRequest(BaseModel):
    id: str = Field(..., description='Must be id linking to a listing')

class SavedItemsPostResponse(BaseModel):
    message: Optional[str] = None


class SavedItemsGetResponse(BaseModel):
    saved_items: Optional[List[ListingGetResponseItem]] = None
    total: Optional[int] = None


class SavedItemsDeleteResponse(BaseModel):
    message: Optional[str] = None


class ReviewPostRequest(BaseModel):
    seller_id: str = Field(..., description='The user ID of the seller being reviewed.')
    rating: confloat(ge=1.0, le=5.0) = Field(
        ..., description='Rating between 1.0 and 5.0.'
    )
    comment: Optional[str] = Field(
        None, description='Optional comment about the seller.'
    )


class ReviewPostResponse(BaseModel):
    message: str


class ReviewItem(BaseModel):
    reviewer_id: Optional[str] = None
    rating: Optional[float] = None
    comment: Optional[str] = None
    timestamp: Optional[datetime] = None


class Conversation(BaseModel):
    conversation_id: Optional[str] = None
    participant_ids: Optional[List[str]] = None
    last_message: Optional[str] = None
    last_timestamp: Optional[datetime] = None


class ConversationsGetResponse(BaseModel):
    conversations: Optional[List[Conversation]] = None


class MessagesGetResponse(BaseModel):
    messages: Optional[List[MessageGetResponseItem]] = None
    total: Optional[int] = None


class SearchGetResponse(BaseModel):
    listings: Optional[List[ListingGetResponseItem]] = None
    total: Optional[int] = None
    next_page_token: Optional[str] = None

class ReviewGetResponse(BaseModel):
    seller_id: Optional[str] = None
    total_reviews: Optional[int] = None
    average_rating: Optional[float] = None
    reviews: Optional[List[ReviewItem]] = None
