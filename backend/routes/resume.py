from fastapi import APIRouter, UploadFile, File, Form, HTTPException
from fastapi.responses import JSONResponse
from agents.input_agent import InputAgent
from services.gemini_agent import gemini_section_parser

router = APIRouter()

@router.post("/evaluate")
async def evaluate(
    resume: UploadFile = File(...),
    job_desc: str = Form(None)
):
    try:
        content = await resume.read()
        extracted_text = InputAgent.parse_resume_file(content, resume.filename)
        # Use Gemini agent for parsing
        sections = gemini_section_parser(extracted_text)
        return JSONResponse({
            "success": True,
            "sections": sections,
            "job_description": job_desc,
            "filename": resume.filename
        })
    except ValueError as ve:
        raise HTTPException(status_code=400, detail=str(ve))
    except Exception as e:
        raise HTTPException(status_code=500, detail="Internal Server Error")
