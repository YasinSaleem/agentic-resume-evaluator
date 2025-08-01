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

const StickyCard = styled.div`
  position: sticky;
  top: 6rem;
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
  height: fit-content;
`;

const MainContainer = styled.div`
  display: flex;
  justify-content: center;
  align-items: flex-start;
  gap: 2rem;
  margin: 4rem auto 0 auto;
  max-width: 1400px;
  width: 100%;
  padding: 0 2rem;
  
  @media (max-width: 1200px) {
    flex-direction: column;
    align-items: center;
    gap: 1.5rem;
  }
`;

const SideColumn = styled.div`
  display: flex;
  flex-direction: column;
  gap: 1.5rem;
  width: 350px;
  
  @media (max-width: 1200px) {
    width: 100%;
    max-width: 420px;
  }
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

const ScoreCard = styled.div`
  background: ${({ theme }) => theme.accent};
  border: 1px solid ${({ theme }) => theme.border};
  border-radius: 12px;
  padding: 1.5rem;
  text-align: center;
`;

const Score = styled.div`
  font-size: 3rem;
  font-weight: 700;
  color: ${({ score }) => {
    if (score >= 8) return '#10b981';
    if (score >= 6) return '#f59e0b';
    return '#ef4444';
  }};
  margin-bottom: 0.5rem;
`;

const ScoreLabel = styled.div`
  font-size: 1rem;
  font-weight: 600;
  color: ${({ theme }) => theme.text};
  margin-bottom: 1rem;
`;

const EvaluationSection = styled.div`
  padding: 1rem;
  background: ${({ theme }) => theme.accent};
  border: 1px solid ${({ theme }) => theme.border};
  border-radius: 12px;
`;

const SectionTitle = styled.div`
  font-weight: 600;
  color: ${({ theme }) => theme.text};
  margin-bottom: 0.5rem;
  font-size: 1rem;
`;

const SectionContent = styled.div`
  font-size: 0.9rem;
  color: ${({ theme }) => theme.text};
  opacity: 0.8;
  line-height: 1.5;
`;

const List = styled.ul`
  margin: 0.5rem 0;
  padding-left: 1.5rem;
`;

const ListItem = styled.li`
  margin-bottom: 0.25rem;
  line-height: 1.4;
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

    if (!jobDesc.trim()) {
      setError("Please provide a job description");
      return;
    }

    setLoading(true);
    setError(null);
    setResult(null);

    try {
      const formData = new FormData();
      formData.append('file', resume);
      formData.append('job_description', jobDesc.trim());

      const response = await fetch('http://127.0.0.1:8000/api/resume/evaluate', {
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
    <>
      {!result ? (
        <Card>
          <Inner>
            <form onSubmit={handleSubmit} autoComplete="off" style={{ width: '100%', display: 'flex', flexDirection: 'column', alignItems: 'center' }}>
              <UploadLabel>
                Upload Your Resume *
                <Input type="file" accept=".pdf,.doc,.docx" onChange={handleResume} required />
              </UploadLabel>
              <UploadLabel>
                Paste Job Description *
                <TextArea
                  rows={5}
                  value={jobDesc}
                  onChange={handleJobDesc}
                  placeholder="Paste the job description to compare your resume (required)"
                  required
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

          <SmallText>
            Your files never leave your device. Minimal. Ad free.
          </SmallText>
        </Card>
      ) : (
        <MainContainer>
          <SideColumn>
            <ScoreCard>
              <Score score={result.evaluation?.suitability_score || 0}>
                {result.evaluation?.suitability_score || 0}/10
              </Score>
              <ScoreLabel>Suitability Score</ScoreLabel>
            </ScoreCard>
            
            <EvaluationSection>
              <SectionTitle>Evaluation Reasoning</SectionTitle>
              <SectionContent>
                {result.evaluation?.reasoning || 'No reasoning available'}
              </SectionContent>
            </EvaluationSection>
            
            {result.evaluation?.strengths && result.evaluation.strengths.length > 0 && (
              <EvaluationSection>
                <SectionTitle>Key Strengths</SectionTitle>
                <List>
                  {result.evaluation.strengths.map((strength, index) => (
                    <ListItem key={index}>{strength}</ListItem>
                  ))}
                </List>
              </EvaluationSection>
            )}
          </SideColumn>
          
          <StickyCard>
            <Inner>
              <form onSubmit={handleSubmit} autoComplete="off" style={{ width: '100%', display: 'flex', flexDirection: 'column', alignItems: 'center' }}>
                <UploadLabel>
                  Upload Your Resume *
                  <Input type="file" accept=".pdf,.doc,.docx" onChange={handleResume} required />
                </UploadLabel>
                <UploadLabel>
                  Paste Job Description *
                  <TextArea
                    rows={5}
                    value={jobDesc}
                    onChange={handleJobDesc}
                    placeholder="Paste the job description to compare your resume (required)"
                    required
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
                  Found {Object.keys(result.sections).length} sections in your resume
                </ResultDescription>
              </ResultMessage>
            )}

            <SmallText>
              Your files never leave your device. Minimal. Ad free.
            </SmallText>
          </StickyCard>
          
          <SideColumn>
            {result.evaluation?.weaknesses && result.evaluation.weaknesses.length > 0 && (
              <EvaluationSection>
                <SectionTitle>Areas for Improvement</SectionTitle>
                <List>
                  {result.evaluation.weaknesses.map((weakness, index) => (
                    <ListItem key={index}>{weakness}</ListItem>
                  ))}
                </List>
              </EvaluationSection>
            )}
            
            {result.evaluation?.recommendations && result.evaluation.recommendations.length > 0 && (
              <EvaluationSection>
                <SectionTitle>Recommendations</SectionTitle>
                <List>
                  {result.evaluation.recommendations.map((recommendation, index) => (
                    <ListItem key={index}>{recommendation}</ListItem>
                  ))}
                </List>
              </EvaluationSection>
            )}
            
            {result.evaluation?.technical_metrics && (
              <EvaluationSection>
                <SectionTitle>Technical Metrics</SectionTitle>
                <SectionContent>
                  <div>Cosine Similarity: {(result.evaluation.technical_metrics.cosine_similarity * 100).toFixed(1)}%</div>
                  <div>Keyword Density: {(result.evaluation.technical_metrics.keyword_density * 100).toFixed(1)}%</div>
                  <div>Knockout Violations: {result.evaluation.technical_metrics.knockout_violations}</div>
                </SectionContent>
              </EvaluationSection>
            )}
          </SideColumn>
        </MainContainer>
      )}
    </>
  );
}
