# backend/app/agents/parsing_agent.py
import re

SECTION_TITLES = [
    "PROFILE", "SUMMARY", "OBJECTIVE", "EDUCATION", "EXPERIENCE", "WORK EXPERIENCE",
    "PROFESSIONAL EXPERIENCE", "PROJECTS", "SKILLS", "TECHNICAL SKILLS",
    "CERTIFICATIONS", "ACHIEVEMENTS", "PUBLICATIONS", "AWARDS"
]
SECTION_REGEX = re.compile(rf"^({'|'.join(SECTION_TITLES)})\b.*", re.IGNORECASE)

def heuristic_section_parser(text):
    lines = [l.strip() for l in text.split('\n') if l.strip()]
    sections = {}
    curr_section = "PROFILE/SUMMARY"
    sections[curr_section] = []
    for line in lines:
        if SECTION_REGEX.match(line):
            curr_section = SECTION_REGEX.match(line).group(0).upper()
            sections[curr_section] = []
        else:
            sections[curr_section].append(line)
    # Flatten sections
    parsed = {k: '\n'.join(v).strip() for k, v in sections.items() if v}
    return parsed

# (Optional, add this method for your LLM integration—see below)
# def llm_section_parser(text, llm_func):
#     """
#     llm_func: Callable that returns LLM output as a dict/JSON given a prompt.
#     """
#     prompt = (
#         "You are an expert resume parser. "
#         "Extract the following sections from this resume text: Profile/Summary, Education, Experience, Projects, "
#         "Skills, Certifications, Achievements, Publications, Awards. "
#         "Return a JSON object mapping each section to its content. "
#         "Resume Text:\n" + text
#     )
#     response = llm_func(prompt)
#     return response  # Expect a dict: {section: content}
