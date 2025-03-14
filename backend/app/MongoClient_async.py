from dotenv import load_dotenv
import os
import motor.motor_asyncio
import certifi

# Load environment variables
load_dotenv()
MONGO_URI = os.getenv("MONGO_URI")
DB_NAME = "marketplace"

# Async MongoDB client
client = motor.motor_asyncio.AsyncIOMotorClient(MONGO_URI, tlsCAFile=certifi.where())
db = client[DB_NAME]
listings_collection = db["listings"]
users_collection = db["users"]  # Reference to listings collection
listings_collection = db["listings"]
users_collection = db["users"]  # Reference to listings collection
# we can add more collections here later

