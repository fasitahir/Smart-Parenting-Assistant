# childManagement.py
from fastapi import APIRouter, HTTPException
from pydantic import BaseModel, Field
from pymongo import MongoClient
from bson import ObjectId
from typing import List
import os

# MongoDB Connection
client = MongoClient("mongodb://localhost:27017/")
db = client.smart_parenting
children_collection = db.children

# Create an APIRouter instance for child management
router = APIRouter()

# Pydantic Model for a Child
class ChildModel(BaseModel):
    name: str = Field(..., min_length=2, max_length=50)
    date_of_birth: str = Field(..., pattern=r"\d{4}-\d{2}-\d{2}")
    gender: str = Field(..., pattern=r"^(Male|Female|Other)$")
    allergies: str = Field(..., description="Most occurring allergies in babies.")
    weight: float = Field(..., ge=1, description="Weight in kg")
    height: float = Field(..., ge=0.5, description="Height in ft")
    parentId: str = Field(..., description="Parent ID")

# MongoDB helper for converting ObjectId
def child_serializer(child) -> dict:
    return {
        "id": str(child["_id"]),
        "name": child["name"],
        "date_of_birth": child["date_of_birth"],
        "gender": child["gender"],
        "allergies": child["allergies"],
        "weight": child["weight"],
        "height": child["height"],
        "parentId": child["parentId"]
    }

# Routes
@router.post("/", response_model=dict)
async def add_child(child: ChildModel):
    print(f"Adding child: {child.dict()}")
    result = children_collection.insert_one(child.dict())
    print(f"Insert result: {result.inserted_id}")

    return {"message": "Child added successfully!", "id": str(result.inserted_id)}


@router.get("/", response_model=List[dict])
async def get_children_by_parent(parentId: str):
    children = children_collection.find({"parentId": parentId})
    children_list = [child_serializer(child) for child in children]
    if not children_list:
        raise HTTPException(status_code=404, detail="No children found for this parent")
    return children_list

@router.get("/{child_id}", response_model=dict)
async def get_child_by_id(child_id: str):
    child = children_collection.find_one({"_id": ObjectId(child_id)})
    if not child:
        raise HTTPException(status_code=404, detail="Child not found")
    return child_serializer(child)

@router.put("/{child_id}", response_model=dict)
async def update_child(child_id: str, updated_child: ChildModel):
    result = children_collection.update_one(
        {"_id": ObjectId(child_id)}, {"$set": updated_child.dict()}
    )
    if result.matched_count == 0:
        raise HTTPException(status_code=404, detail="Child not found")
    return {"message": "Child updated successfully"}

@router.delete("/{child_id}", response_model=dict)
async def delete_child(child_id: str):
    print(f"Deleting child with ID: {child_id}")
    result = children_collection.delete_one({"_id": ObjectId(child_id)})
    if result.deleted_count == 0:
        raise HTTPException(status_code=404, detail="Child not found")
    return {"message": "Child deleted successfully"}
