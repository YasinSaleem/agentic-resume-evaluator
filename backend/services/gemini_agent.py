import os
import google.generativeai as genai

genai.configure(api_key=os.getenv("GEMINI_API_KEY"))

def gemini_section_parser(text: str) -> dict:
    prompt = (
        "You are a professional resume parser. Extract the following sections from the resume text below: "
        "Profile/Summary, Education, Experience, Projects, Skills, Certifications, Achievements, Publications, Awards.\n"
        "Return a JSON object mapping each section to its content.\n\n"
        f"Resume Text:\n{text}"
    )

    model = genai.GenerativeModel("gemini-pro")
    response = model.generate_content(prompt)

    try:
        return eval(response.text)  # ✅ Or use json.loads(response.text) if it's proper JSON
    except Exception as e:
        return {"error": f"Parsing Gemini output failed: {str(e)}"}
