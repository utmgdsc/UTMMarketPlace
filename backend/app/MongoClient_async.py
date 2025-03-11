from dotenv import load_dotenv
import os
import motor.motor_asyncio

# Load environment variables
load_dotenv()
MONGO_URI = os.getenv("MONGO_URI")
DB_NAME = "marketplace"

# Async MongoDB client
client = motor.motor_asyncio.AsyncIOMotorClient(MONGO_URI)
db = client[DB_NAME]
listings_collection = db["listings"]  # Reference to listings collection
# we can add more collections here later
users_collection = db["users"]  # Reference to users collection
