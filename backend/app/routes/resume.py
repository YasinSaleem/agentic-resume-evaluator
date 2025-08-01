from fastapi import APIRouter, UploadFile, File, Form, HTTPException
from fastapi.responses import JSONResponse
from app.agents.input_agent import InputAgent
from app.agents.parsing_agent import heuristic_section_parser
# from app.agents.parsing_agent import llm_section_parser, llm_func  # See below for LLM setup

router = APIRouter()

@router.post("/evaluate")
async def evaluate(
    resume: UploadFile = File(...),
    job_desc: str = Form(None)
):
    try:
        content = await resume.read()
        extracted_text = InputAgent.parse_resume_file(content, resume.filename)
        # Use heuristic parser for now
        sections = heuristic_section_parser(extracted_text)
        # For LLM: uncomment and implement llm_func to call Gemini or another API.
        # sections = llm_section_parser(extracted_text, llm_func)
        return JSONResponse({
            "sections": sections,
            "job_description": job_desc
        })
    except ValueError as ve:
        raise HTTPException(status_code=400, detail=str(ve))
    except Exception as e:
        raise HTTPException(status_code=500, detail="Internal Server Error")
