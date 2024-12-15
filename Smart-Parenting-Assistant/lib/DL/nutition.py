from fastapi import APIRouter, HTTPException
from pydantic import BaseModel
from typing import List, Optional
import google.generativeai as genai
import os
import re
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
# async def get_nutrition_assist(child_data: ChildData):
#     """
#     Generate a personalized and concise nutrition plan for a child.
#     """
#     # Construct prompt with child details, including growth and allergies
#     prompt = (
#         f"Provide a concise, professionally advised diet plan for a child with the following details:\n"
#         f"Date of Birth: {child_data.date_of_birth}\n"
#         f"Weight: {child_data.weight} kg\n"
#         f"Height: {child_data.height} ft\n"
#         f"Allergies: {child_data.allergies}\n"
#         f"Milestones Achieved: {', '.join(child_data.milestones) if child_data.milestones else 'None'}\n"
#         f"Gender: {child_data.gender}\n"
#         f"Ensure the diet plan addresses overgrowth or stunted growth concerns if applicable, avoids allergens, "
#         f"and includes essential nutrients for the child's development. Use simple language, and provide actionable items."
#     )

#     # Get response from the model
#     response = chat_session.send_message(prompt)

#     # Format the response for the frontend
#     diet_plan = {
#         "header": "Personalized Nutrition Plan",
#         "sections": []
#     }
#     # Split the response into sections if possible
#     sections = response.text.split("\n\n")
#     for section in sections:
#         lines = section.strip().split("\n")
#         if len(lines) > 1:
#             diet_plan["sections"].append({
#                 "title": lines[0].strip(),  # Use the first line as a section title
#                 "content": " ".join(lines[1:]).strip()  # Combine the rest into the content
#             })
#         else:
#             diet_plan["sections"].append({
#                 "title": "General Advice",
#                 "content": lines[0].strip()
#             })
#     if not diet_plan["sections"]:
#         diet_plan["sections"].append({
#         "title": "No Suggestions",
#         "content": "Unable to generate a diet plan. Please consult a professional."
#         })

#     return {"diet_plan": diet_plan}
# 
async def get_nutrition_assist(child_data: ChildData):
    """
    Generate a personalized and concise nutrition plan for a child.
    """
    # Validate input data
    if child_data.height <= 0 or child_data.weight <= 0:
        return {
            "diet_plan": {
                "general_advice": [
                    {
                        "title": "General Advice",
                        "content": "Invalid height or weight provided. Please enter realistic values."
                    }
                ],
                "diet_suggestions": []
            }
        }

    # Construct prompt
    prompt = (
        f"Create two sections for the child's nutrition plan:\n"
        f"1. General Advice: Provide general nutritional guidance.\n"
        f"2. Diet Plan: Include actionable items based on the provided details.\n"
        f"Child's details: DOB - {child_data.date_of_birth}, Weight - {child_data.weight} kg, "
        f"Height - {child_data.height} ft, Allergies - {child_data.allergies}, Gender - {child_data.gender}."
    )

    # Get response from the model
    response = chat_session.send_message(prompt)

    # Log response for debugging
    print("Model Response:", response.text)

    # Separate general advice and diet plan suggestions
    general_advice = []
    diet_suggestions = []

    # Check if response is empty
    if not response.text.strip():
        return {
            "diet_plan": {
                "general_advice": [
                    {
                        "title": "General Advice",
                        "content": "The AI model was unable to generate suggestions. Please verify the input data and try again."
                    }
                ],
                "diet_suggestions": []
            }
        }

    # Split the response into sections
    # sections = [sec.strip() for sec in response.text.split("\n\n") if sec.strip()]
    # for section in sections:
    #     lines = section.split("\n")
    #     if len(lines) > 1:
    #         title = lines[0].strip().lower()
    #         content = " ".join(lines[1:]).strip()

    #         if "general advice" in title:
    #             general_advice.append(content)
    #         else:
    #             diet_suggestions.append({"title": lines[0].strip(), "content": content})
    #     else:
    #         general_advice.append(section.strip())


    # # Build the structured response
    # diet_plan = {"general_advice": [], "diet_suggestions": []}

    # if general_advice:
    #     diet_plan["general_advice"].append({
    #         "title": "General Advice",
    #         "content": " ".join(general_advice)
    #     })

    # if diet_suggestions:
    #     diet_plan["diet_suggestions"] = diet_suggestions

    # # Handle cases with no suggestions
    # if not general_advice and not diet_suggestions:
    #     diet_plan["general_advice"].append({
    #         "title": "No Suggestions",
    #         "content": "Unable to generate a diet plan. Please consult a professional."
    #     })

    # return {"diet_plan": diet_plan}
    # sections = [sec.strip() for sec in response.text.split("\n") if sec.strip()]
    sections = response.text.split("\n\n")
    general_advice = []
    diet_suggestions = []
    # print('--------------------------------Sections-------------------------------------------')
    # print(sections)
    # print('--------------------------------Sections-------------------------------------------')

    for section in sections:
        # lines = section.split("\n")
        lines = section.strip().split("\n")
        if len(lines) > 1:
            title = lines[0].strip().lower()
            # Join content lines with newline to preserve bullet formatting
            # content = "\n".join(line.strip() for line in lines[1:]).strip()
            # content = re.sub(r"^\\s", "", content, flags=re.MULTILINE)
            content_lines = [
                line.lstrip("* ").strip() for line in lines[1:] if line.strip()
            ]
            content = "\n".join(content_lines)
            print('---------------------------------------------------------------------------')
            print(content)
            if "General Advice" in title:
                general_advice.append(content)
            else :
                diet_suggestions.append({"title": lines[0].strip(), "content": content})
        else:
            general_advice.append(section.strip())

    # Build the structured response
    diet_plan = {"general_advice": [], "diet_suggestions": []}

    if general_advice:
        diet_plan["general_advice"].append({
            "title": "General Advice",
            "content": "\n".join(general_advice)  # Join advice with line breaks for clarity
        })

    if diet_suggestions:
        diet_plan["diet_suggestions"] = diet_suggestions

    # Handle cases with no suggestions
    if not general_advice and not diet_suggestions:
        diet_plan["general_advice"].append({
            "title": "No Suggestions",
            "content": "Unable to generate a diet plan. Please consult a professional."
        })
    # print('--------------------------------Final Output-------------------------------------------')
    # print(diet_plan)
    # print('--------------------------------Final Output-------------------------------------------')
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