import { ThemeProvider, Global, css } from '@emotion/react';
import { useTheme } from '../hooks/useTheme';
import { lightTheme, darkTheme } from '../utils/theme';

export default function App({ Component, pageProps }) {
  const [theme, toggleTheme] = useTheme();
  const activeTheme = theme === 'dark' ? darkTheme : lightTheme;

  return (
    <ThemeProvider theme={activeTheme}>
      <Global
        styles={css`
          html, body {
            background: ${activeTheme.background};
            color: ${activeTheme.text};
            font-family: 'Inter', Arial, sans-serif;
            font-weight: 400;
            font-size: 16px;
            line-height: 1.5;
            transition: background 0.2s, color 0.2s;
            min-height: 100vh;
            margin: 0;
            padding: 0;
          }
          h1, h2, h3, h4, h5, h6 {
            font-weight: 600;
            line-height: 1.2;
          }
          button {
            font-weight: 500;
            letter-spacing: 0.025em;
          }
          small {
            font-size: 14px;
            font-weight: 400;
          }
          a {
            color: inherit;
            text-decoration: none;
          }
        `}
      />
      <div style={{
        minHeight: '100vh',
        display: 'flex',
        flexDirection: 'column'
      }}>
        <header style={{
          position: 'sticky',
          top: 0,
          zIndex: 1000,
          width: '100%',
          display: 'flex',
          justifyContent: 'space-between',
          alignItems: 'center',
          padding: '1rem 2rem',
          background: activeTheme.card,
          borderBottom: `1px solid ${activeTheme.border}`,
          boxShadow: '0 1px 3px rgba(0,0,0,0.05)',
          boxSizing: 'border-box'
        }}>
          <div style={{
            fontSize: '1.2rem',
            fontWeight: '700',
            color: activeTheme.text,
            lineHeight: '1.2'
          }}>
            Resume Evaluator
          </div>
          <button
            onClick={toggleTheme}
            style={{
              background: theme === 'light' ? activeTheme.accent : '#e3e311ff', // Use stone-100 for dark mode button
              color: activeTheme.text,
              border: `1px solid ${activeTheme.border}`,
              borderRadius: '50%',
              width: '44px',
              height: '44px',
              fontSize: '1.3rem',
              cursor: 'pointer',
              boxShadow: '0px 2px 8px rgba(0,0,0,0.08)',
              display: 'flex',
              alignItems: 'center',
              justifyContent: 'center',
              flexShrink: 0,
              transition: 'all 0.2s ease'
            }}
            aria-label="Toggle dark/light mode"
          >
            <img
              src={theme === 'light' ? '/icons/dark_mode.png' : '/icons/light_mode.png'}
              alt={theme === 'light' ? 'Switch to dark mode' : 'Switch to light mode'}
              width="24"
              height="24"
              style={{ filter: 'none' }}
            />
          </button>
        </header>
        <main style={{ flex: 1 }}>
          <Component {...pageProps} />
        </main>
      </div>
    </ThemeProvider>
  );
}
