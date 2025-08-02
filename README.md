# Resume Evaluator with AI-Powered Suitability Scoring

This project provides an intelligent resume evaluation system that uses Gemini AI to analyze resume suitability against job descriptions.

<img width="1290" height="735" alt="Screenshot 2025-08-02 at 11 08 47 AM" src="https://github.com/user-attachments/assets/30ea3336-a03c-4e89-b723-144e461bf739" />

<img width="1288" height="734" alt="Screenshot 2025-08-02 at 11 09 32 AM" src="https://github.com/user-attachments/assets/bf173232-ee41-4de3-9d0b-852e3dac2575" />

## Features

### 1. Resume Parsing
- Extracts structured information from resumes (PDF, DOC, DOCX)
- Parses sections: Education, Experience, Skills, Projects, Certifications, Achievements
- Uses Gemini AI for intelligent text extraction and structuring

### 2. Resume Evaluation
- **Suitability Scoring**: Provides a score out of 10 based on multiple criteria
- **Cosine Similarity**: Measures text similarity between resume and job description using TF-IDF
- **Keyword Density Analysis**: Evaluates how well resume matches job requirements
- **Knockout Criteria**: Identifies missing required skills or qualifications
- **AI-Powered Analysis**: Uses Gemini to provide detailed reasoning and recommendations

## Technical Implementation

### Backend Architecture

#### Services
- `gemini_agent.py`: Handles resume section parsing
- `resume_evaluator.py`: New service for resume evaluation and scoring

#### Evaluation Metrics
1. **Cosine Similarity**: Uses scikit-learn TF-IDF vectorization
2. **Keyword Density**: Analyzes keyword overlap between resume and job description
3. **Knockout Criteria**: Checks for missing required skills/qualifications
4. **AI Evaluation**: Gemini provides comprehensive analysis and scoring

#### API Endpoints
- `POST /api/resume/evaluate`: Evaluates resume against job description
- Returns structured evaluation with score, reasoning, and recommendations

### Frontend Features
- Modern, responsive UI with theme support
- Real-time evaluation display
- Visual score representation with color coding
- Detailed breakdown of strengths, weaknesses, and recommendations
- Technical metrics display

## Installation and Setup

### Prerequisites
- Python 3.8+
- Node.js 14+
- Gemini API key

### Backend Setup
```bash
cd backend
pip install -r requirements.txt
```

### Frontend Setup
```bash
cd frontend
npm install
```

### Environment Variables
Create a `.env` file in the backend directory:
```
GEMINI_API_KEY=your_gemini_api_key_here
```

## Usage

### Running the Application

1. **Start Backend**:
```bash
cd backend
uvicorn main:app --reload
```

2. **Start Frontend**:
```bash
cd frontend
npm run dev
```

3. **Access Application**: Open `http://localhost:3000`

### Using the Resume Evaluator

1. Upload your resume (PDF, DOC, or DOCX)
2. Paste the job description
3. Click "Evaluate Resume"
4. View the suitability score and detailed analysis

## Evaluation Criteria

### Scoring System (1-10)
- **8-10**: Excellent match with strong qualifications
- **6-7**: Good match with minor gaps
- **4-5**: Moderate match with significant gaps
- **1-3**: Poor match with major deficiencies

### Technical Metrics
- **Cosine Similarity**: Text similarity score (0-1)
- **Keyword Density**: Keyword overlap percentage
- **Knockout Violations**: Number of missing required criteria

### AI Analysis Components
- **Strengths**: Key positive aspects of the resume
- **Weaknesses**: Areas needing improvement
- **Recommendations**: Specific suggestions for enhancement
- **Reasoning**: Detailed explanation of the score

## API Response Format

```json
{
  "success": true,
  "sections": {
    "EDUCATION": {...},
    "EXPERIENCE": {...},
    "SKILLS": {...},
    "PROJECTS": [...]
  },
  "evaluation": {
    "suitability_score": 8,
    "reasoning": "Detailed analysis...",
    "strengths": ["Strong technical skills", "Relevant experience"],
    "weaknesses": ["Limited leadership experience"],
    "recommendations": ["Add more leadership examples"],
    "technical_metrics": {
      "cosine_similarity": 0.85,
      "keyword_density": 0.78,
      "knockout_violations": 0
    },
    "knockout_checks": {
      "required_skills_missing": false,
      "knockout_reasons": []
    }
  }
}
```

## Testing

Run the test script to verify the evaluator:
```bash
cd backend
python test_evaluator.py
```

## Dependencies

### Backend
- FastAPI: Web framework
- Google Generative AI: Gemini integration
- scikit-learn: TF-IDF and cosine similarity
- numpy: Numerical computations
- python-multipart: File upload handling
- PyPDF2, python-docx: Document parsing

### Frontend
- Next.js: React framework
- Emotion: Styled components
- React hooks for state management

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests if applicable
5. Submit a pull request

## License

This project is licensed under the MIT License. 
