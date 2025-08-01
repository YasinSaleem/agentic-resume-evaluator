import { useState } from 'react';
import styled from '@emotion/styled';

const Card = styled.div`
  margin: 4rem auto 0 auto;
  background: ${({ theme }) => theme.card};
  border-radius: 20px;
  box-shadow: 0 4px 25px rgba(0,0,0,0.08);
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
  line-height: 1.2;
`;

const Input = styled.input`
  padding: 0.9rem;
  border-radius: 12px;
  border: 1px solid ${({ theme }) => theme.border};
  background: ${({ theme }) => theme.background};
  width: 100%;
  margin-bottom: 1.5rem;
  font-weight: 400;
  line-height: 1.5;
  transition: border-color 0.2s ease;
  &:focus {
    outline: none;
    border-color: ${({ theme }) => theme.button};
  }
  &::placeholder {
    font-weight: 400;
    color: ${({ theme }) => theme.muted};
  }
`;

const Button = styled.button`
  padding: 0.8rem 2.2rem;
  background: ${({ theme }) => theme.button};
  color: ${({ theme }) => theme.buttonText};
  border: none;
  border-radius: 12px;
  font-weight: 500;
  letter-spacing: 0.025em;
  cursor: pointer;
  font-size: 1.1rem;
  transition: all 0.2s ease;
  box-shadow: 0 2px 8px rgba(0,0,0,0.1);
  &:hover {
    transform: translateY(-1px);
    box-shadow: 0 4px 12px rgba(0,0,0,0.15);
  }
  &:disabled {
    opacity: 0.6;
    cursor: not-allowed;
    transform: none;
    box-shadow: 0 2px 8px rgba(0,0,0,0.1);
  }
`;

const LoadingMessage = styled.div`
  text-align: center;
  color: ${({ theme }) => theme.text};
  font-size: 1rem;
  font-weight: 400;
  margin-top: 1rem;
  opacity: 0.8;
  line-height: 1.5;
`;

const ResultMessage = styled.div`
  text-align: center;
  color: ${({ theme }) => theme.text};
  font-size: 1rem;
  font-weight: 400;
  margin-top: 1rem;
  padding: 1rem;
  border-radius: 12px;
  background: ${({ theme }) => theme.accent};
  border: 1px solid ${({ theme }) => theme.border};
  line-height: 1.5;
`;

const SmallText = styled.div`
  font-size: 14px;
  font-weight: 400;
  text-align: center;
  color: ${({ theme }) => theme.muted};
  line-height: 1.5;
`;

const ResultTitle = styled.div`
  font-weight: 600;
  margin-bottom: 0.5rem;
  line-height: 1.2;
`;

const ResultDescription = styled.div`
  font-size: 0.9rem;
  font-weight: 400;
  opacity: 0.8;
  line-height: 1.5;
`;

const TextArea = styled.textarea`
  width: 100%;
  border-radius: 12px;
  border: 1px solid ${({ theme }) => theme.border};
  padding: 0.9rem;
  background: ${({ theme }) => theme.background};
  color: ${({ theme }) => theme.text};
  margin-bottom: 1.5rem;
  font-family: inherit;
  font-weight: 400;
  line-height: 1.5;
  resize: none;
  transition: border-color 0.2s ease;
  &:focus {
    outline: none;
    border-color: ${({ theme }) => theme.button};
  }
  &::placeholder {
    color: ${({ theme }) => theme.muted};
  }
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
            Paste Job Description
            <TextArea
              rows={5}
              value={jobDesc}
              onChange={handleJobDesc}
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
        <ResultMessage style={{ 
          color: '#ef4444',
          background: '#fef2f2',
          borderColor: '#fecaca'
        }}>
          Error: {error}
        </ResultMessage>
      )}

      {result && (
        <ResultMessage>
          <ResultTitle>
            Analysis Complete!
          </ResultTitle>
          <ResultDescription>
            Found {Object.keys(result.parsed_sections).length} sections in your resume
          </ResultDescription>
        </ResultMessage>
      )}

      <SmallText>
        Your files never leave your device. Minimal. Ad free.
      </SmallText>
    </Card>
  );
}
