from fastapi import APIRouter, HTTPException
from pydantic import BaseModel
from typing import List, Optional
import google.generativeai as genai
import os

router = APIRouter()

# Configure API Key
with open("D:\\FasiTahir\\apiKey.txt", "r") as file:
    key = file.read().strip()
genai.configure(api_key=key)

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
    milestones: Optional[List[str]] = []
    allergies: str
    gender: str


@router.post("/nutrition/")
async def get_nutrition_assist(child_data: ChildData):
    """
    Generate a personalized and concise nutrition plan for a child.
    """
    # Construct prompt with child details, including growth and allergies
    prompt = (
        f"Provide a concise, professionally advised diet plan for a child with the following details:\n"
        f"Date of Birth: {child_data.date_of_birth}\n"
        f"Weight: {child_data.weight} kg\n"
        f"Height: {child_data.height} ft\n"
        f"Allergies: {child_data.allergies}\n"
        f"Milestones Achieved: {', '.join(child_data.milestones) if child_data.milestones else 'None'}\n"
        f"Gender: {child_data.gender}\n"
        f"Ensure the diet plan addresses overgrowth or stunted growth concerns if applicable, avoids allergens, "
        f"and includes essential nutrients for the child's development. Use simple language, and provide actionable items."
    )

    # Get response from the model
    response = chat_session.send_message(prompt)

    # Format the response for the frontend
    diet_plan = {
        "header": "Personalized Nutrition Plan",
        "sections": []
    }
    # Split the response into sections if possible
    sections = response.text.split("\n\n")
    for section in sections:
        lines = section.strip().split("\n")
        if len(lines) > 1:
            diet_plan["sections"].append({
                "title": lines[0].strip(),  # Use the first line as a section title
                "content": " ".join(lines[1:]).strip()  # Combine the rest into the content
            })
        else:
            diet_plan["sections"].append({
                "title": "General Advice",
                "content": lines[0].strip()
            })
    if not diet_plan["sections"]:
        diet_plan["sections"].append({
        "title": "No Suggestions",
        "content": "Unable to generate a diet plan. Please consult a professional."
        })

    return {"diet_plan": diet_plan}


# Follow-up question handler
def ask_follow_up(question):
    """
    Handle follow-up questions in the same chat session.
    :param question: Follow-up question from the parent
    :return: Model's response
    """
    response = chat_session.send_message(question)
    return response.text
