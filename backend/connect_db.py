from dotenv import load_dotenv
import os
from pymongo import MongoClient
import certifi

load_dotenv()  # Load environment variables from .env
MONGO_URI = os.getenv("MONGO_URI")  
DB_NAME = "marketplace"

client = MongoClient(MONGO_URI, tlsCAFile=certifi.where())
db = client[DB_NAME]


def test_db_connection():
    try:
        client = MongoClient(MONGO_URI)
        db = client[DB_NAME]
        
        # Create a test collection
        test_collection = db["test_collection"]
        
        # Insert a test document
        test_data = {"message": "Hello, MongoDB!"}
        test_collection.insert_one(test_data)
        
        # Retrieve and print the inserted document
        result = test_collection.find_one({"message": "Hello, MongoDB!"})
        print("Inserted document:", result)

        # Close the connection
        client.close()
    except Exception as e:
        print("Error:", e)

if __name__ == "__main__":
    test_db_connection()