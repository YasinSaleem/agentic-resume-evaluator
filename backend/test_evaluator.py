#!/usr/bin/env python3
"""
Test script for the resume evaluator
"""

import sys
import os
sys.path.append(os.path.dirname(os.path.abspath(__file__)))

from services.resume_evaluator import gemini_resume_evaluator

# Sample parsed resume sections
sample_parsed_sections = {
    "EDUCATION": {
        "institutions": [
            {
                "name": "University of Technology",
                "degree": "Bachelor of Science",
                "field": "Computer Science",
                "year": "2020",
                "gpa": "3.8"
            }
        ]
    },
    "EXPERIENCE": {
        "positions": [
            {
                "title": "Software Engineer",
                "company": "Tech Corp",
                "duration": "2021-2023",
                "description": "Developed web applications using Python, JavaScript, and React. Led a team of 3 developers."
            }
        ]
    },
    "SKILLS": {
        "technical": ["Python", "JavaScript", "React", "Node.js", "SQL"],
        "soft_skills": ["Leadership", "Communication", "Problem Solving"],
        "languages": ["English", "Spanish"]
    },
    "PROJECTS": [
        {
            "name": "E-commerce Platform",
            "description": "Built a full-stack e-commerce application",
            "technologies": ["React", "Node.js", "MongoDB"],
            "url": "https://github.com/user/ecommerce"
        }
    ]
}

# Sample job description
sample_job_description = """
Software Engineer Position

We are looking for a skilled Software Engineer with the following requirements:

Required Skills:
- Python programming experience
- JavaScript and React knowledge
- Database experience (SQL)
- Team collaboration skills

Qualifications:
- Bachelor's degree in Computer Science or related field
- 2+ years of experience in software development
- Experience with web development technologies

Responsibilities:
- Develop and maintain web applications
- Collaborate with cross-functional teams
- Write clean, maintainable code
- Participate in code reviews
"""

def test_evaluator():
    """Test the resume evaluator with sample data"""
    print("Testing Resume Evaluator...")
    print("=" * 50)
    
    try:
        result = gemini_resume_evaluator(sample_parsed_sections, sample_job_description)
        
        print(f"Suitability Score: {result.get('suitability_score', 'N/A')}/10")
        print(f"Reasoning: {result.get('reasoning', 'N/A')}")
        
        if 'strengths' in result:
            print(f"\nStrengths:")
            for strength in result['strengths']:
                print(f"- {strength}")
        
        if 'weaknesses' in result:
            print(f"\nWeaknesses:")
            for weakness in result['weaknesses']:
                print(f"- {weakness}")
        
        if 'recommendations' in result:
            print(f"\nRecommendations:")
            for rec in result['recommendations']:
                print(f"- {rec}")
        
        if 'technical_metrics' in result:
            metrics = result['technical_metrics']
            print(f"\nTechnical Metrics:")
            print(f"- Cosine Similarity: {metrics.get('cosine_similarity', 0):.3f}")
            print(f"- Keyword Density: {metrics.get('keyword_density', 0):.3f}")
            print(f"- Knockout Violations: {metrics.get('knockout_violations', 0)}")
        
        print("\nTest completed successfully!")
        
    except Exception as e:
        print(f"Error during testing: {str(e)}")
        import traceback
        traceback.print_exc()

if __name__ == "__main__":
    test_evaluator() 