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

export default function Home() {
  const [resume, setResume] = useState(null);
  const [jobDesc, setJobDesc] = useState("");
  const [loading, setLoading] = useState(false);

  function handleResume(e) {
    setResume(e.target.files[0]);
  }

  function handleJobDesc(e) {
    setJobDesc(e.target.value);
  }

  async function handleSubmit(e) {
    e.preventDefault();
    setLoading(true);
    // Handle file upload and API call here
    setTimeout(() => setLoading(false), 1200); // Mock delay
  }

  return (
    <Card>
      <Inner>
        <form onSubmit={handleSubmit} autoComplete="off" style={{ width: '100%' }}>
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
      <div style={{ fontSize: '0.99rem', textAlign: 'center', opacity: 0.6 }}>
        Your files never leave your device. Minimal. Ad free.
      </div>
    </Card>
  );
}
