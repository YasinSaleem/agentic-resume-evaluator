# DUMMY FILE
# backend/app/main.py
from fastapi import FastAPI
from app.routes import resume

app = FastAPI(title="AI Resume Evaluator Backend")

@app.get("/")
async def root():
    return {"message": "AI Resume Evaluator Backend is running"}

# Include API router with prefix /api
app.include_router(resume.router, prefix="/api")
