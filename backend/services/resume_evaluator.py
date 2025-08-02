import os
import json
import numpy as np
from sklearn.feature_extraction.text import TfidfVectorizer
from sklearn.metrics.pairwise import cosine_similarity
from dotenv import load_dotenv
import google.generativeai as genai
import re

# Load environment variables from .env file
load_dotenv()

genai.configure(api_key=os.getenv("GEMINI_API_KEY"))

def calculate_text_similarity(text1: str, text2: str) -> float:
    """
    Calculate cosine similarity between two texts using TF-IDF
    """
    if not text1.strip() or not text2.strip():
        return 0.0
    
    vectorizer = TfidfVectorizer(stop_words='english', lowercase=True)
    try:
        tfidf_matrix = vectorizer.fit_transform([text1, text2])
        similarity = cosine_similarity(tfidf_matrix[0:1], tfidf_matrix[1:2])[0][0]
        return float(similarity)
    except Exception:
        return 0.0

def extract_keywords(text: str) -> list:
    """
    Extract important keywords from text
    """
    # Remove special characters and convert to lowercase
    text = re.sub(r'[^\w\s]', '', text.lower())
    words = text.split()
    
    # Filter out common stop words and short words
    stop_words = {'the', 'a', 'an', 'and', 'or', 'but', 'in', 'on', 'at', 'to', 'for', 'of', 'with', 'by', 'is', 'are', 'was', 'were', 'be', 'been', 'have', 'has', 'had', 'do', 'does', 'did', 'will', 'would', 'could', 'should', 'may', 'might', 'can', 'this', 'that', 'these', 'those', 'i', 'you', 'he', 'she', 'it', 'we', 'they', 'me', 'him', 'her', 'us', 'them'}
    
    keywords = [word for word in words if len(word) > 2 and word not in stop_words]
    return keywords

def calculate_keyword_density(resume_text: str, job_description: str) -> float:
    """
    Calculate keyword density score
    """
    job_keywords = extract_keywords(job_description)
    resume_keywords = extract_keywords(resume_text)
    
    if not job_keywords:
        return 0.0
    
    # Count how many job keywords appear in resume
    matched_keywords = sum(1 for keyword in job_keywords if keyword in resume_keywords)
    density = matched_keywords / len(job_keywords)
    
    return min(density, 1.0)

def check_knockout_criteria(parsed_sections: dict, job_description: str) -> dict:
    """
    Check for knockout criteria (must-have requirements)
    """
    knockout_checks = {
        "required_skills_missing": False,
        "experience_gap": False,
        "education_mismatch": False,
        "knockout_reasons": []
    }
    
    # Extract required skills from job description
    job_text = job_description.lower()
    required_skills = []
    
    # Common required skills patterns
    skill_patterns = [
        r'required.*?skills?[:\s]*([^.]*)',
        r'must.*?have[:\s]*([^.]*)',
        r'requirements[:\s]*([^.]*)',
        r'qualifications[:\s]*([^.]*)'
    ]
    
    for pattern in skill_patterns:
        matches = re.findall(pattern, job_text, re.IGNORECASE)
        if matches:
            required_skills.extend(matches)
    
    # Check if required skills are present in resume
    if required_skills:
        resume_text = json.dumps(parsed_sections).lower()
        for skill_group in required_skills:
            skills = skill_group.split(',')
            for skill in skills:
                skill = skill.strip()
                if skill and skill not in resume_text:
                    knockout_checks["required_skills_missing"] = True
                    knockout_checks["knockout_reasons"].append(f"Missing required skill: {skill}")
    
    return knockout_checks

def gemini_resume_evaluator(parsed_sections: dict, job_description: str) -> dict:
    """
    Evaluate resume suitability using Gemini and various metrics
    """
    # Prepare resume text for analysis
    resume_text = ""
    if "EXPERIENCE" in parsed_sections:
        for position in parsed_sections["EXPERIENCE"].get("positions", []):
            resume_text += f"{position.get('title', '')} {position.get('company', '')} {position.get('description', '')} "
    
    if "SKILLS" in parsed_sections:
        skills = parsed_sections["SKILLS"]
        resume_text += f"{' '.join(skills.get('technical', []))} {' '.join(skills.get('soft_skills', []))} {' '.join(skills.get('languages', []))} "
    
    if "EDUCATION" in parsed_sections:
        for institution in parsed_sections["EDUCATION"].get("institutions", []):
            resume_text += f"{institution.get('degree', '')} {institution.get('field', '')} "
    
    if "PROJECTS" in parsed_sections:
        for project in parsed_sections["PROJECTS"]:
            resume_text += f"{project.get('name', '')} {project.get('description', '')} {' '.join(project.get('technologies', []))} "
    
    # Calculate metrics
    similarity_score = calculate_text_similarity(resume_text, job_description)
    keyword_density = calculate_keyword_density(resume_text, job_description)
    knockout_checks = check_knockout_criteria(parsed_sections, job_description)
    
    # Create prompt for Gemini evaluation
    prompt = f"""
    You are an expert HR professional evaluating a resume against a job description.
    
    Job Description:
    {job_description}
    
    Parsed Resume Sections:
    {json.dumps(parsed_sections, indent=2)}
    
    Technical Metrics:
    - Cosine Similarity Score: {similarity_score:.3f}
    - Keyword Density Score: {keyword_density:.3f}
    - Knockout Criteria Violations: {len(knockout_checks['knockout_reasons'])}
    
    Please evaluate this resume for the job and provide:
    1. A suitability score out of 10 (considering relevance, experience match, skills alignment)
    2. Detailed reasoning for the score
    3. Key strengths and weaknesses
    4. Specific recommendations for improvement
    
    Consider:
    - Experience relevance and duration
    - Skills match with job requirements
    - Education alignment
    - Project relevance
    - Overall fit for the role
    
    Return your response as a JSON object with the following structure:
    {{
        "suitability_score": <score_out_of_10>,
        "reasoning": "<detailed_reasoning>",
        "strengths": ["<strength1>", "<strength2>"],
        "weaknesses": ["<weakness1>", "<weakness2>"],
        "recommendations": ["<recommendation1>", "<recommendation2>"],
        "technical_metrics": {{
            "cosine_similarity": {similarity_score},
            "keyword_density": {keyword_density},
            "knockout_violations": {len(knockout_checks['knockout_reasons'])}
        }}
    }}
    """
    
    try:
        model = genai.GenerativeModel("gemini-2.0-flash")
        response = model.generate_content(prompt)
        
        # Parse Gemini response
        response_text = response.text.strip()
        
        # Extract JSON from response
        if response_text.startswith("```json"):
            response_text = response_text.split("```json")[1].split("```")[0]
        elif response_text.startswith("```"):
            response_text = response_text.split("```")[1].split("```")[0]
        
        try:
            evaluation_result = json.loads(response_text)
            
            # Add knockout information
            evaluation_result["knockout_checks"] = knockout_checks
            
            return evaluation_result
            
        except json.JSONDecodeError as e:
            # Fallback response if JSON parsing fails
            return {
                "suitability_score": max(0, min(10, int((similarity_score + keyword_density) * 5))),
                "reasoning": "Automated scoring based on technical metrics due to parsing error",
                "strengths": ["Technical analysis completed"],
                "weaknesses": ["Could not parse detailed evaluation"],
                "recommendations": ["Review resume manually for detailed feedback"],
                "technical_metrics": {
                    "cosine_similarity": similarity_score,
                    "keyword_density": keyword_density,
                    "knockout_violations": len(knockout_checks['knockout_reasons'])
                },
                "knockout_checks": knockout_checks,
                "error": f"JSON parsing failed: {str(e)}"
            }
            
    except Exception as e:
        return {
            "suitability_score": 0,
            "reasoning": f"Evaluation failed: {str(e)}",
            "strengths": [],
            "weaknesses": ["Technical error in evaluation"],
            "recommendations": ["Please try again or contact support"],
            "technical_metrics": {
                "cosine_similarity": similarity_score,
                "keyword_density": keyword_density,
                "knockout_violations": len(knockout_checks['knockout_reasons'])
            },
            "knockout_checks": knockout_checks,
            "error": f"Gemini API call failed: {str(e)}"
        } 