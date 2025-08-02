import os
import json
from dotenv import load_dotenv
import google.generativeai as genai

# Load environment variables from .env file
load_dotenv()

genai.configure(api_key=os.getenv("GEMINI_API_KEY"))

def gemini_section_parser(text: str) -> dict:
    prompt = """
    You are a professional resume parser. Extract and structure the following sections from the resume text below.
    
    Return a JSON object with the following structure:
    {
        "EDUCATION": {
            "institutions": [
                {
                    "name": "Institution Name",
                    "degree": "Degree Type",
                    "field": "Field of Study",
                    "year": "Year",
                    "gpa": "GPA if mentioned"
                }
            ]
        },
        "EXPERIENCE": {
            "positions": [
                {
                    "title": "Job Title",
                    "company": "Company Name",
                    "duration": "Duration/Period",
                    "description": "Job Description"
                }
            ]
        },
        "SKILLS": {
            "technical": ["skill1", "skill2"],
            "soft_skills": ["skill1", "skill2"],
            "languages": ["language1", "language2"]
        },
        "PROJECTS": [
            {
                "name": "Project Name",
                "description": "Project Description",
                "technologies": ["tech1", "tech2"],
                "url": "Project URL if mentioned"
            }
        ],
        "CERTIFICATIONS": [
            {
                "name": "Certification Name",
                "issuer": "Issuing Organization",
                "year": "Year Obtained"
            }
        ],
        "ACHIEVEMENTS": [
            "Achievement 1",
            "Achievement 2"
        ]
    }
    
    Only include sections that are present in the resume. If a section is not found, omit it from the JSON.
    Be specific and detailed in extracting information.
    
    Resume Text:
    """ + text

    try:
        model = genai.GenerativeModel("gemini-2.0-flash")
        response = model.generate_content(prompt)
        
        # Try to parse the response as JSON
        try:
            # Clean the response text to extract JSON
            response_text = response.text.strip()
            
            # Find JSON content (sometimes Gemini wraps it in markdown)
            if response_text.startswith("```json"):
                response_text = response_text.split("```json")[1].split("```")[0]
            elif response_text.startswith("```"):
                response_text = response_text.split("```")[1].split("```")[0]
            
            parsed_response = json.loads(response_text)
            return parsed_response
            
        except json.JSONDecodeError as e:
            # If JSON parsing fails, return a fallback structure
            return {
                "error": "Failed to parse Gemini response as JSON",
                "raw_response": response.text,
                "json_error": str(e)
            }
            
    except Exception as e:
        return {
            "error": f"Gemini API call failed: {str(e)}",
            "text_length": len(text)
        }
