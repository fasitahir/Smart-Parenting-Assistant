from fastapi import APIRouter, HTTPException
from pydantic import BaseModel, EmailStr
from pymongo import MongoClient
import bcrypt

# Database connection
client = MongoClient("mongodb://localhost:27017/")
db = client.smart_parenting
users_collection = db.users

# Create an APIRouter instance for registration
router = APIRouter()

# Models
class User(BaseModel):
    email: EmailStr
    password: str

@router.post("/signup")
async def signup(user: User):
    if users_collection.find_one({"email": user.email}):
        raise HTTPException(status_code=400, detail="Email already registered")
    password_hash = bcrypt.hashpw(user.password.encode('utf-8'), bcrypt.gensalt())
    users_collection.insert_one({"email": user.email, "password": password_hash.decode()})
    return {"message": "User registered successfully"}

class LoginRequest(BaseModel):
    email: EmailStr
    password: str

@router.post("/login")
async def login(request: LoginRequest):
    user = users_collection.find_one({"email": request.email})
    if not user:
        raise HTTPException(status_code=400, detail="User not found")
    if not bcrypt.checkpw(request.password.encode('utf-8'), user["password"].encode('utf-8')):
        raise HTTPException(status_code=400, detail="Invalid credentials")
    return {"message": "Login successful", "user_id": str(user["_id"])}
