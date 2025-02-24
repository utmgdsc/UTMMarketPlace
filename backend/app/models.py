# generated by fastapi-codegen:
#   filename:  OpenAPI.yaml
#   timestamp: 2025-02-20T22:36:02+00:00

from __future__ import annotations

from typing import Optional

from pydantic import BaseModel, EmailStr, Field, SecretStr


class SignUpPostRequest(BaseModel):
    email: EmailStr = Field(
        ...,
        description='Must be a valid University of Toronto email (utoronto.ca or mail.utoronto.ca).',
        example='student@utoronto.ca',
    )
    password: SecretStr = Field(
        ...,
        description='Must be at least 8 characters, contain 1 uppercase letter, 1 number.',
        example='P@ssword123',
    )


class SignUpPostResponse(BaseModel):
    user_id: int = Field(..., example=42)
    message: Optional[str] = Field(None, example='User registered successfully.')


class SignUpPostResponse1(BaseModel):
    error: str = Field(..., example='Invalid email format. Please use a UofT email.')


class SignUpPostResponse2(BaseModel):
    error: str = Field(..., example='Email already registered.')


class ListingsGetResponseItem(BaseModel):
    id: Optional[str] = Field(None, example=1)
    title: Optional[str] = Field(None, example='MacBook Pro for sale')
    price: Optional[float] = Field(None, example=1200.99)
    description: Optional[str] = Field(
        None, example='Selling my MacBook Pro in great condition!'
    )
    seller_id: Optional[int] = Field(None, example=101)


class ListingGetResponse(BaseModel):
    error: Optional[str] = Field(
        None, example='Invalid listing ID format. Must be a valid ObjectId.'
    )


class ListingGetResponse1(BaseModel):
    error: Optional[str] = Field(None, example='Listing not found.')


class ListingsGetAllResponse(BaseModel):
    listings: List[ListingsGetResponseItem]
    total: int  # (we can use for pagination)


class ListingsPostRequest(BaseModel):
    title: Optional[str] = Field(None, example='Gaming Laptop for sale')
    price: Optional[float] = Field(None, example=899.99)
    description: Optional[str] = Field(
        None, example='Lightly used gaming laptop, great condition!'
    )
    seller_id: Optional[int] = Field(None, example=101)



class ListingsPostResponse(BaseModel):
    id: Optional[str] = Field(None, example=10)
    title: Optional[str] = Field(None, example='Gaming Laptop for sale')
    price: Optional[float] = Field(None, example=899.99)
    description: Optional[str] = Field(
        None, example='Lightly used gaming laptop, great condition!'
    )
    message: Optional[str] = Field(None, example='Listing created successfully.')
