from fastapi import APIRouter, HTTPException
from pymongo import MongoClient
from pydantic import BaseModel

# Database connection
client = MongoClient("mongodb://localhost:27017/")
db = client.smart_parenting
reminders_collection = db.reminders

# APIRouter instance
router = APIRouter()

# Reminder Model
class Reminder(BaseModel):
    title: str
    date: str  # ISO 8601 date format
    time: str  # 24-hour time format

@router.put("/{title}")
async def update_reminder(title: str, reminder: Reminder):
    # Try to find the reminder by its title
    result = reminders_collection.update_one(
        {"title": title}, {"$set": reminder.dict()}
    )
    
    if result.matched_count == 0:
        raise HTTPException(status_code=404, detail="Reminder not found")

    return {"message": "Reminder updated successfully"}



@router.post("/")
async def add_reminder(reminder: Reminder):
    reminder_id = reminders_collection.insert_one(reminder.dict()).inserted_id
    return {"message": "Reminder added successfully", "id": str(reminder_id)}

@router.get("/")
async def get_reminders():
    reminders = list(reminders_collection.find({}, {"_id": 0}))
    return reminders

@router.delete("/{title}")
async def delete_reminder(title: str):
    result = reminders_collection.delete_one({"title": title})
    if result.deleted_count > 0:
        return {"message": "Reminder deleted successfully"}
    return {"message": "Reminder not found"}, 404
