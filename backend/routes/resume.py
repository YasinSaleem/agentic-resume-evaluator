from fastapi import APIRouter, UploadFile, File, Form, HTTPException
from fastapi.responses import JSONResponse
from agents.input_agent import InputAgent
from services.gemini_agent import gemini_section_parser
from services.resume_evaluator import gemini_resume_evaluator

router = APIRouter()

@router.post("/evaluate")
async def evaluate(
    file: UploadFile = File(...),
    job_description: str = Form(...)
):
    try:
        content = await file.read()
        extracted_text = InputAgent.parse_resume_file(content, file.filename)
        # Use Gemini agent for parsing
        sections = gemini_section_parser(extracted_text)
        
        # Evaluate resume with job description
        evaluation = gemini_resume_evaluator(sections, job_description)
        
        return JSONResponse({
            "success": True,
            "sections": sections,
            "job_description": job_description,
            "filename": file.filename,
            "evaluation": evaluation
        })
    except ValueError as ve:
        raise HTTPException(status_code=400, detail=str(ve))
    except Exception as e:
        raise HTTPException(status_code=500, detail="Internal Server Error")
