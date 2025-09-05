#!/bin/bash

# EC2 Deployment Script with PM2 (Alternative to Docker)
# Run this script on your EC2 instance for PM2-based deployment

set -e

echo "🚀 Starting PM2-based deployment on EC2..."

# Update system packages
sudo apt update && sudo apt upgrade -y

# Install Node.js 18 LTS
if ! command -v node &> /dev/null; then
    echo "📦 Installing Node.js 18..."
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
    sudo apt install python3.12 python3.12-venv python3.12-dev python3-pip -y
    
    # Create symlink for python3
    sudo ln -sf /usr/bin/python3.12 /usr/bin/python3
fi

# Install PM2 globally
if ! command -v pm2 &> /dev/null; then
    echo "📦 Installing PM2..."
    sudo npm install -g pm2
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

# Create logs directory
mkdir -p logs

# Setup Backend
echo "🐍 Setting up backend..."
cd backend

# Create virtual environment
python3.12 -m venv venv
source venv/bin/activate

# Install Python dependencies
pip install --upgrade pip
pip install -r requirements.txt

# Create environment file if it doesn't exist
if [ ! -f ".env" ]; then
    cp .env.example .env
    echo "❗ Please update backend/.env with your Gemini API key"
fi

cd ..

# Setup Frontend
echo "⚛️ Setting up frontend..."
cd frontend

# Install dependencies and build
npm ci
npm run build

cd ..

# Update environment files for production
echo "⚙️ Updating environment files..."
cat > backend/.env << EOF
GEMINI_API_KEY=\${GEMINI_API_KEY:-your_gemini_api_key_here}
HOST=0.0.0.0
PORT=8000
ENVIRONMENT=production
ALLOWED_ORIGINS=http://localhost:3000,https://\$(curl -s ifconfig.me)
EOF

cat > frontend/.env << EOF
NEXT_PUBLIC_API_URL=http://localhost:8000
NODE_ENV=production
EOF

# Setup PM2 processes
echo "🔧 Starting PM2 processes..."
pm2 start ecosystem.config.js --env production
pm2 save
pm2 startup

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

echo "✅ PM2 Deployment complete!"
echo ""
echo "🔧 Next steps:"
echo "1. Update backend/.env with your Gemini API key:"
echo "   echo 'GEMINI_API_KEY=your_actual_key_here' > backend/.env"
echo "2. Restart PM2 processes: pm2 restart all"
echo "3. Update Nginx config with your actual domain name if needed"
echo "4. Consider setting up SSL with Let's Encrypt"
echo ""
echo "📍 Your application should be available at: http://\$(curl -s ifconfig.me)"
echo "📊 Check PM2 status: pm2 status"
echo "📋 View PM2 logs: pm2 logs"
echo "📊 Monitor PM2: pm2 monit"
