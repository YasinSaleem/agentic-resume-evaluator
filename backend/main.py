from fastapi import FastAPI, UploadFile, File
from fastapi.middleware.cors import CORSMiddleware
from backend.agents.parsing_agent import heuristic_section_parser
from backend.services.gemini_agent import gemini_section_parser
from backend.agents.input_agent import InputAgent

app = FastAPI()

# Allow requests from frontend (adjust origin in production)
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # Change to specific domain in production
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

@app.get("/")
async def root():
    return {"message": "✅ Smart Resume Evaluator API is running. Use /docs to try it out."}

@app.post("/parse-resume/")
async def parse_resume(file: UploadFile = File(...), method: str = "heuristic"):
    file_bytes = await file.read()
    filename = file.filename

    try:
        text = InputAgent.parse_resume_file(file_bytes, filename)
    except ValueError as e:
        return {"error": str(e)}

    if method == "gemini":
        result = gemini_section_parser(text)
    else:
        result = heuristic_section_parser(text)

    return {"parsed": result}
