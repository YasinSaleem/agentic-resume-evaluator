from fastapi import FastAPI, UploadFile, File
from fastapi.middleware.cors import CORSMiddleware
from services.gemini_agent import gemini_section_parser
from agents.input_agent import InputAgent
from routes.resume import router as resume_router

app = FastAPI()

# Allow requests from frontend (adjust origin in production)
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # Change to specific domain in production
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Include routers
app.include_router(resume_router, prefix="/api/resume", tags=["resume"])

@app.get("/")
async def root():
    return {"message": "Smart Resume Evaluator API is running. Use /docs to try it out."}

@app.get("/health")
async def health_check():
    return {"status": "healthy", "service": "resume-evaluator-api"}

@app.post("/parse-resume/")
async def parse_resume(file: UploadFile = File(...)):
    file_bytes = await file.read()
    filename = file.filename

    try:
        # Extract text from resume using InputAgent
        extracted_text = InputAgent.parse_resume_file(file_bytes, filename)
        
        # Parse the extracted text using Gemini agent
        result = gemini_section_parser(extracted_text)
        
        return {
            "success": True,
            "filename": filename,
            "parsed_sections": result,
            "raw_text_length": len(extracted_text)
        }
        
    except ValueError as e:
        return {
            "success": False,
            "error": str(e),
            "filename": filename
        }
    except Exception as e:
        return {
            "success": False,
            "error": f"Unexpected error: {str(e)}",
            "filename": filename
        }
