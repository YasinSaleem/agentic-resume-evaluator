import { useState } from 'react';
import styled from '@emotion/styled';

const Card = styled.div`
  margin: 4rem auto 0 auto;
  background: ${({ theme }) => theme.card};
  border-radius: 20px;
  box-shadow: 0 2px 28px rgba(0,0,0,0.10);
  max-width: 420px;
  width: 100%;
  padding: 2.5rem 2rem;
  border: 1px solid ${({ theme }) => theme.border};
  display: flex;
  flex-direction: column;
  gap: 2rem;
`;

const Inner = styled.div`
  display: flex;
  flex-direction: column;
  align-items: center;
  padding-left: 1rem;
  padding-right: 2.2rem;
  @media (max-width: 600px) {
    padding-left: 0.5rem;
    padding-right: 0.5rem;
  }
`;

const UploadLabel = styled.label`
  font-weight: 600;
  font-size: 1.1rem;
  color: ${({ theme }) => theme.text};
  display: block;
  margin-bottom: 1rem;
`;

const Input = styled.input`
  padding: 0.9rem;
  border-radius: 12px;
  border: 1px solid ${({ theme }) => theme.border};
  background: ${({ theme }) => theme.background};
  width: 100%;
  margin-bottom: 1.5rem;
`;

const Button = styled.button`
  padding: 0.8rem 2.2rem;
  background: ${({ theme }) => theme.button};
  color: ${({ theme }) => theme.buttonText};
  border: none;
  border-radius: 12px;
  font-weight: bold;
  cursor: pointer;
  font-size: 1.1rem;
  transition: background 0.2s, color 0.2s;
  &:hover {
    opacity: 0.89;
  }
`;

const LoadingMessage = styled.div`
  text-align: center;
  color: ${({ theme }) => theme.text};
  font-size: 1rem;
  margin-top: 1rem;
  opacity: 0.8;
`;

const ResultMessage = styled.div`
  text-align: center;
  color: ${({ theme }) => theme.text};
  font-size: 1rem;
  margin-top: 1rem;
  padding: 1rem;
  border-radius: 12px;
  background: ${({ theme }) => theme.background};
  border: 1px solid ${({ theme }) => theme.border};
`;

export default function Home() {
  const [resume, setResume] = useState(null);
  const [jobDesc, setJobDesc] = useState("");
  const [loading, setLoading] = useState(false);
  const [result, setResult] = useState(null);
  const [error, setError] = useState(null);

  function handleResume(e) {
    setResume(e.target.files[0]);
    setResult(null);
    setError(null);
  }

  function handleJobDesc(e) {
    setJobDesc(e.target.value);
  }

  async function handleSubmit(e) {
    e.preventDefault();
    
    if (!resume) {
      setError("Please select a resume file");
      return;
    }

    setLoading(true);
    setError(null);
    setResult(null);

    try {
      const formData = new FormData();
      formData.append('file', resume);

      const response = await fetch('http://127.0.0.1:8000/parse-resume/', {
        method: 'POST',
        body: formData,
      });

      const data = await response.json();

      if (data.success) {
        setResult(data);
      } else {
        setError(data.error || 'Failed to analyze resume');
      }
    } catch (err) {
      setError('Network error. Please check if the backend server is running.');
    } finally {
      setLoading(false);
    }
  }

  return (
    <Card>
      <Inner>
        <form onSubmit={handleSubmit} autoComplete="off" style={{ width: '100%', display: 'flex', flexDirection: 'column', alignItems: 'center' }}>
          <UploadLabel>
            Upload Your Resume
            <Input type="file" accept=".pdf,.doc,.docx" onChange={handleResume} required />
          </UploadLabel>
          <UploadLabel>
            (Optional) Paste Job Description
            <textarea
              rows={5}
              value={jobDesc}
              onChange={handleJobDesc}
              style={{
                width: '100%',
                borderRadius: '12px',
                border: '1px solid #ececec',
                padding: '0.9rem',
                background: 'inherit',
                color: 'inherit',
                marginBottom: '1.5rem',
                fontFamily: 'inherit',
                resize: 'none'
              }}
              placeholder="Paste the job description to compare your resume"
            />
          </UploadLabel>
          <Button type="submit" disabled={loading}>
            {loading ? 'Analyzing...' : 'Evaluate Resume'}
          </Button>
        </form>
      </Inner>
      
      {loading && (
        <LoadingMessage>
          Your resume is being analyzed...
        </LoadingMessage>
      )}

      {error && (
        <ResultMessage style={{ color: '#e74c3c' }}>
          Error: {error}
        </ResultMessage>
      )}

      {result && (
        <ResultMessage>
          <div style={{ fontWeight: 'bold', marginBottom: '0.5rem' }}>
            Analysis Complete!
          </div>
          <div style={{ fontSize: '0.9rem', opacity: 0.8 }}>
            Found {Object.keys(result.parsed_sections).length} sections in your resume
          </div>
        </ResultMessage>
      )}

      <div style={{ fontSize: '0.99rem', textAlign: 'center', opacity: 0.6 }}>
        Your files never leave your device. Minimal. Ad free.
      </div>
    </Card>
  );
}
