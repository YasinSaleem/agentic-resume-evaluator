// frontend/hooks/useTheme.js
import { useState, useEffect } from 'react';

export function useTheme() {
  const [theme, setTheme] = useState('light');

  useEffect(() => {
    const stored = localStorage.getItem('theme');
    if (stored) setTheme(stored);
  }, []);

  const toggleTheme = () => {
    const updated = theme === 'light' ? 'dark' : 'light';
    setTheme(updated);
    localStorage.setItem('theme', updated);
  };

  return [theme, toggleTheme];
}
