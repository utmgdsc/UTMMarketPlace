import asyncio
from motor.motor_asyncio import AsyncIOMotorClient
import certifi
import os
from dotenv import load_dotenv

# Load environment variables
load_dotenv()
MONGO_URI = os.getenv("MONGO_URI")
DB_NAME = "marketplace"

async def cleanup_listings():
    # Connect to MongoDB
    client = AsyncIOMotorClient(MONGO_URI, tlsCAFile=certifi.where())
    db = client[DB_NAME]
    listings_collection = db["listings"]
    
    # Get all document IDs sorted by date
    cursor = listings_collection.find().sort("date_posted", -1)
    all_docs = await cursor.to_list(length=None)
    
    if len(all_docs) <= 10:
        print("Less than or equal to 10 documents found. No cleanup needed.")
        return
    
    # Get IDs to delete (skip first 10)
    ids_to_delete = [doc["_id"] for doc in all_docs[10:]]
    
    # Delete documents
    result = await listings_collection.delete_many({"_id": {"$in": ids_to_delete}})
    print(f"Deleted {result.deleted_count} documents")
    
    # Close connection
    client.close()

if __name__ == "__main__":
    asyncio.run(cleanup_listings()) 