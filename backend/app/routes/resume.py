# backend/app/routes/resume.py
from fastapi import APIRouter

router = APIRouter()

@router.post("/evaluate")
async def evaluate():
    # Placeholder response to confirm it works
    return {
        "message": "Resume evaluation endpoint is live",
        "result": None
    }
