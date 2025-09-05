#!/bin/bash

# Local Development Setup Script
# Run this script to set up the project for local development

set -e

echo "🚀 Setting up Resume Evaluator for local development..."

# Check if Node.js is installed
if ! command -v node &> /dev/null; then
    echo "❌ Node.js is not installed. Please install Node.js 18+ first."
    exit 1
fi

# Check if Python 3.12 is installed
if ! command -v python3.12 &> /dev/null; then
    echo "❌ Python 3.12 is not installed. Please install Python 3.12 first."
    exit 1
fi

# Setup backend
echo "🐍 Setting up backend..."
cd backend

# Create virtual environment
if [ ! -d "venv" ]; then
    python3.12 -m venv venv
fi

# Activate virtual environment and install dependencies
source venv/bin/activate
pip install --upgrade pip
pip install -r requirements.txt

# Create .env file if it doesn't exist
if [ ! -f ".env" ]; then
    cp .env.example .env
    echo "📝 Created backend/.env - Please add your Gemini API key"
fi

cd ..

# Setup frontend
echo "⚛️ Setting up frontend..."
cd frontend

# Install dependencies
npm install

# Create .env file if it doesn't exist
if [ ! -f ".env" ]; then
    cp .env.example .env
    echo "📝 Created frontend/.env"
fi

cd ..

echo "✅ Setup complete!"
echo ""
echo "🚀 To start development:"
echo "1. Add your Gemini API key to backend/.env"
echo "2. Start backend: cd backend && uvicorn main:app --reload --host 0.0.0.0 --port 8000"
echo "3. Start frontend: cd frontend && npm run dev"
echo ""
echo "🌐 Frontend: http://localhost:3000"
echo "🔧 Backend API: http://localhost:8000"
echo "📚 API Docs: http://localhost:8000/docs"
