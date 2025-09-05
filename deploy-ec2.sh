#!/bin/bash

# EC2 Deployment Script for Resume Evaluator
# Run this script on your EC2 instance

set -e

echo "🚀 Starting deployment on EC2..."

# Update system packages
sudo apt update && sudo apt upgrade -y

# Install Docker if not present
if ! command -v docker &> /dev/null; then
    echo "📦 Installing Docker..."
    curl -fsSL https://get.docker.com -o get-docker.sh
    sudo sh get-docker.sh
    sudo usermod -aG docker $USER
    rm get-docker.sh
fi

# Install Docker Compose if not present
if ! command -v docker-compose &> /dev/null; then
    echo "📦 Installing Docker Compose..."
    sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
    sudo chmod +x /usr/local/bin/docker-compose
fi

# Install Node.js 18 (for frontend build)
if ! command -v node &> /dev/null; then
    echo "📦 Installing Node.js..."
    curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
    sudo apt-get install -y nodejs
fi

# Install Python 3.12 if not present
if ! command -v python3.12 &> /dev/null; then
    echo "📦 Installing Python 3.12..."
    sudo apt update
    sudo apt install software-properties-common -y
    sudo add-apt-repository ppa:deadsnakes/ppa -y
    sudo apt update
    sudo apt install python3.12 python3.12-venv python3.12-dev -y
fi

# Install nginx for reverse proxy
if ! command -v nginx &> /dev/null; then
    echo "📦 Installing Nginx..."
    sudo apt install nginx -y
fi

# Clone repository (if not already present)
if [ ! -d "agentic-resume-evaluator" ]; then
    echo "📥 Cloning repository..."
    git clone https://github.com/YasinSaleem/agentic-resume-evaluator.git
fi

cd agentic-resume-evaluator

# Create environment files from examples
echo "⚙️ Setting up environment files..."
if [ ! -f "backend/.env" ]; then
    cp backend/.env.example backend/.env
    echo "❗ Please update backend/.env with your Gemini API key"
fi

if [ ! -f "frontend/.env" ]; then
    cp frontend/.env.example frontend/.env
    echo "❗ Please update frontend/.env with your production API URL"
fi

# Install frontend dependencies
echo "📦 Installing frontend dependencies..."
cd frontend
npm ci --production
cd ..

# Build and start services
echo "🏗️ Building and starting services..."
docker-compose up --build -d

# Setup Nginx reverse proxy
echo "🔧 Setting up Nginx reverse proxy..."
sudo tee /etc/nginx/sites-available/resume-evaluator > /dev/null <<EOF
server {
    listen 80;
    server_name _; # Replace with your domain

    # Frontend
    location / {
        proxy_pass http://localhost:3000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
        proxy_cache_bypass \$http_upgrade;
    }

    # Backend API
    location /api/ {
        proxy_pass http://localhost:8000/api/;
        proxy_http_version 1.1;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
        
        # Handle file uploads
        client_max_body_size 50M;
    }

    # Health check
    location /health {
        proxy_pass http://localhost:8000/health;
    }
}
EOF

# Enable the site
sudo ln -sf /etc/nginx/sites-available/resume-evaluator /etc/nginx/sites-enabled/
sudo rm -f /etc/nginx/sites-enabled/default

# Test and restart Nginx
sudo nginx -t && sudo systemctl restart nginx

# Enable services to start on boot
sudo systemctl enable nginx
sudo systemctl enable docker

echo "✅ Deployment complete!"
echo ""
echo "🔧 Next steps:"
echo "1. Update backend/.env with your Gemini API key"
echo "2. Update frontend/.env with your production domain"
echo "3. Update Nginx config with your actual domain name"
echo "4. Consider setting up SSL with Let's Encrypt"
echo ""
echo "📍 Your application should be available at: http://$(curl -s ifconfig.me)"
echo "📊 Check status: docker-compose ps"
echo "📋 View logs: docker-compose logs -f"
