from fastapi import APIRouter, HTTPException
from pydantic import BaseModel
from typing import List
from datetime import datetime
from pymongo import MongoClient

# MongoDB Setup
client = MongoClient("mongodb://localhost:27017/")
db = client.growth_monitor
growth_collection = db.growth_data
children_collection = db.children

# FastAPI App
router = APIRouter()

# Pydantic Models
class GrowthData(BaseModel):
    child_id: str
    date: datetime
    weight: float
    height: float
    milestone: str = None

class ChildProfile(BaseModel):
    name: str
    date_of_birth: datetime
    gender: str
    allergies: str
    weight: float
    height: float
    parentId: str

@router.post("/children", status_code=201)
async def add_child(child: ChildProfile):
    # Insert child profile
    child_data = child.dict()
    result = children_collection.insert_one(child_data)

    if not result.acknowledged:
        raise HTTPException(status_code=500, detail="Failed to add child")

    # Add initial growth data for the child
    growth_data = {
        "child_id": str(result.inserted_id),
        "date": datetime.utcnow(),
        "weight": child.weight,
        "height": child.height,
        "milestone": "Initial Data"
    }
    growth_collection.insert_one(growth_data)

    return {"message": "Child added successfully"}

@router.post("/growth", status_code=201)
async def add_growth(data: GrowthData):
    # Add growth data
    growth_data = data.dict()
    result = growth_collection.insert_one(growth_data)

    if not result.acknowledged:
        raise HTTPException(status_code=500, detail="Failed to add growth data")

    # Update child's height and weight in their profile
    update_result = children_collection.update_one(
        {"_id": data.child_id},
        {"$set": {"weight": data.weight, "height": data.height}}
    )

    if update_result.matched_count == 0:
        raise HTTPException(status_code=404, detail="Child not found")

    return {"message": "Growth data added and child profile updated"}

@router.get("/children", response_model=List[ChildProfile])
async def get_children():
    return list(children_collection.find({}, {"_id": 0}))
