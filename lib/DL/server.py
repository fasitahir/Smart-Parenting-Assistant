from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
import os
from dotenv import load_dotenv

# Import routers from child management and other modules
from lib.DL.childManagement import router as child_management_router
from lib.DL.registration import router as registration_router
from lib.DL.reminder_data import router as reminder_data_router
from lib.DL.nutition import router as nutrition_data_router
from lib.DL.growthMonitor import router as growth_monitor_router


# Load environment variables (like database URI or port)
load_dotenv()

# Initialize the main FastAPI app
app = FastAPI()

# Middleware setup (similar to CORS in Flask)
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # Adjust to your needs
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Register the child management and registration routers
app.include_router(child_management_router, prefix="/children", tags=["Children"])
app.include_router(registration_router, prefix="", tags=["Auth"])
app.include_router(reminder_data_router, prefix="/reminders", tags=["Reminders"])
app.include_router(nutrition_data_router, prefix="", tags=["Nutrition"])
app.include_router(growth_monitor_router, prefix="", tags=["Growth Monitor"])

# Add a simple health check route
@app.get("/health")
async def health_check():
    return {"status": "ok"}

# Run the app (only when this file is executed directly)
if __name__ == '__main__':
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=int(os.getenv('PORT', 8000)))
