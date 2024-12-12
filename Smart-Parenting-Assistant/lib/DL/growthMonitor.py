from fastapi import APIRouter, HTTPException
from fastapi.responses import JSONResponse
from pydantic import BaseModel
from typing import List
from datetime import datetime
from pymongo import MongoClient
from bson import ObjectId
from fastapi import APIRouter, HTTPException

# MongoDB Setup
client = MongoClient("mongodb://localhost:27017/")
db = client.smart_parenting
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


@router.post("/growth/initial")
async def add_child(child: GrowthData):
    print("Adding child initial growth data")
    # Insert child profile
    child_data = child.dict()
    result = growth_collection.insert_one(child_data)

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

    response_data =  {"message": "Child added successfully"}
    return JSONResponse(response_data, status_code=201)

@router.post("/growth/add")
async def add_growth(data: GrowthData):
    # Add growth data
    growth_data = data.dict()
    result = growth_collection.insert_one(growth_data)
    if result is None:
        raise HTTPException(status_code=500, detail="Failed to add growth data")
    # Update child's height and weight in their profile
    print("child_id: ", ObjectId(data.child_id))
    update_result = children_collection.update_one(
        {"_id": ObjectId(data.child_id)},
        {"$set": {"weight": data.weight, "height": data.height}}
    )

    if update_result.matched_count == 0:
        raise HTTPException(status_code=404, detail="Child not found")
    
    response_data = {"message": "Growth data added successfully"}
    return JSONResponse(response_data, status_code=201)



@router.get("/growth-detection/{child_id}")
async def detect_growth(child_id: str):
    # Get the latest growth data for the child
    latest_data = growth_collection.find_one(
        {"child_id": child_id},
        sort=[("date", -1)]
    )

    if latest_data is None:
        raise HTTPException(status_code=404, detail="Child not found or no data available")

    # Check if the child's growth is within normal range
    # (For simplicity, we are not implementing the actual growth detection logic here)
    return {"message": "Growth data detected", "data": latest_data}



@router.get("/growth/getGrowthData/{child_id}")
async def get_growth_data(child_id: str):
    try:
        growth_data = list(growth_collection.find({"child_id": child_id}).sort("date", 1))
        if not growth_data:
            raise HTTPException(status_code=404, detail="No growth data found for this child")
        response_data = {"message": "Growth data found", "data": growth_data}
        
        for data in growth_data:
            data["_id"] = str(data["_id"])

        for data in growth_data:
            if "date" in data:  # Replace "date" with the actual field name
                data["date"] = data["date"].isoformat()
        
    
        return JSONResponse(response_data, status_code=200)
        
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))
