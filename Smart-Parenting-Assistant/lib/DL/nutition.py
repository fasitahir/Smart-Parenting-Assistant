from pydantic import BaseModel
from typing import Optional, List
import os
import google.generativeai as genai
from fastapi import APIRouter, HTTPException
from pydantic import BaseModel
from typing import List, Optional
import time

router = APIRouter()
# Configure API Key
genai.configure(api_key="AIzaSyDv63B20hCJJkplVhmsRu6KtFu3d6xk2X0")  # Replace with your API key

# Create the model
generation_config = {
    "temperature": 0.7,
    "top_p": 0.9,
    "top_k": 40,
    "max_output_tokens": 512,
    "response_mime_type": "text/plain",
}

model = genai.GenerativeModel(
    model_name="gemini-1.5-flash",
    generation_config=generation_config,
)



# Initialize chat session
chat_session = model.start_chat(history=[])


class ChildData(BaseModel):
    date_of_birth: str
    weight: float
    height: float
    #milestones: Optional[List[str]] = []

@router.post("/nutrition/")
async def get_nutrition_assist(child_data: ChildData):
    """
    Generate personalized nutrition suggestions for a child.
    """
    print("hello")
    print("Child Data: ", child_data)
    # Construct the prompt with validated child data
    prompt = (
        f"Provide concise, evidence-based nutrition suggestions for a child with the following details: "
        f"Date of Birth: {child_data.date_of_birth}, Weight: {child_data.weight} kg, Height: {child_data.height} ft. "
        f"Ensure that the response is tailored to the child's development and highlights important dietary guidelines."
    )

    response = chat_session.send_message(prompt)
    return {"suggestions": response.text}


# Follow-up question handler
def ask_follow_up(question):
    """
    Handle follow-up questions in the same chat session.
    :param question: Follow-up question from the parent
    :return: model's response
    """
    response = chat_session.send_message(question)
    return response.text
