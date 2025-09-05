# EC2 Deployment Guide - Resume Evaluator

This guide provides complete step-by-step instructions to deploy the Resume Evaluator application on a fresh Amazon Linux 2 EC2 instance using PM2.

## Prerequisites

### 1. EC2 Instance Setup
- **AMI**: Amazon Linux 2 AMI (HVM)
- **Instance Type**: t3.medium or larger (recommended)
- **Storage**: 20 GB GP3
- **Security Group**: Configure inbound rules for:
  - Port 22 (SSH) - Your IP
  - Port 80 (HTTP) - 0.0.0.0/0
  - Port 443 (HTTPS) - 0.0.0.0/0
  - Port 3000 (Frontend) - 0.0.0.0/0
  - Port 8000 (Backend API) - 0.0.0.0/0

### 2. Required API Keys
- **Gemini API Key**: Get from [Google AI Studio](https://aistudio.google.com/app/apikey)

## Complete Deployment Steps

### Step 1: Connect to EC2 Instance

```bash
# SSH into your EC2 instance (replace with your key and IP)
ssh -i your-key.pem ec2-user@YOUR_EC2_IP
```

### Step 2: Clone and Setup Repository

```bash
# Clone the repository
git clone https://github.com/YasinSaleem/agentic-resume-evaluator.git
cd agentic-resume-evaluator

# Switch to deployment branch
git checkout deployment

# Make deployment script executable
chmod +x deploy-ec2-pm2.sh
chmod +x start-backend.sh
```

### Step 3: Run Automated Deployment

```bash
# Run the deployment script (this installs everything)
./deploy-ec2-pm2.sh
```

The script automatically installs:
- Node.js 18 LTS
- Python 3 and virtual environment
- PM2 process manager
- Nginx web server
- All project dependencies
- Builds the frontend application

### Step 4: Configure Environment Variables

#### A. Backend Environment Configuration

```bash
cd ~/agentic-resume-evaluator/backend
nano .env
```

**Replace the entire content with (update YOUR_EC2_IP and YOUR_GEMINI_API_KEY):**

```bash
GEMINI_API_KEY=YOUR_GEMINI_API_KEY
HOST=0.0.0.0
PORT=8000
ENVIRONMENT=production
ALLOWED_ORIGINS=http://localhost:3000,http://YOUR_EC2_IP:3000,http://YOUR_EC2_IP
```

**Example with real values:**
```bash
GEMINI_API_KEY=AIzaSyBRqkJ1gW-wUnj8RItfQUjMzEm0ln4Y5y0
HOST=0.0.0.0
PORT=8000
ENVIRONMENT=production
ALLOWED_ORIGINS=http://localhost:3000,http://3.107.13.168:3000,http://3.107.13.168
```

#### B. Frontend Environment Configuration

```bash
cd ~/agentic-resume-evaluator/frontend
nano .env.local
```

**Add this content (replace YOUR_EC2_IP):**

```bash
NEXT_PUBLIC_API_URL=http://YOUR_EC2_IP:8000
NODE_ENV=production
```

**Example with real values:**
```bash
NEXT_PUBLIC_API_URL=http://3.107.13.168:8000
NODE_ENV=production
```

### Step 5: Build and Start Application

```bash
cd ~/agentic-resume-evaluator

# Rebuild frontend with environment variables
cd frontend && npm run build && cd ..

# Start PM2 processes
pm2 start ecosystem.config.js --env production

# Save PM2 configuration for auto-restart
pm2 save

# Setup PM2 to start on system boot
pm2 startup
# Follow the command provided by pm2 startup
```

### Step 6: Verify Deployment

#### Check PM2 Status
```bash
pm2 status
```

**Expected output:**
```
┌─────┬──────────────────────────────┬─────────────┬─────────┬─────────┬──────────┬────────┬──────┬───────────┬──────────┬──────────┬──────────┬──────────┐
│ id  │ name                         │ namespace   │ version │ mode    │ pid      │ uptime │ ↺    │ status    │ cpu      │ mem      │ user     │ watching │
├─────┼──────────────────────────────┼─────────────┼─────────┼─────────┼──────────┼────────┼──────┼───────────┼──────────┼──────────┼──────────┼──────────┤
│ 0   │ resume-evaluator-backend     │ default     │ N/A     │ fork    │ 12345    │ 10s    │ 0    │ online    │ 0%       │ 50.0mb   │ ec2-user │ disabled │
│ 1   │ resume-evaluator-frontend    │ default     │ N/A     │ fork    │ 12346    │ 8s     │ 0    │ online    │ 0%       │ 100.0mb  │ ec2-user │ disabled │
└─────┴──────────────────────────────┴─────────────┴─────────┴─────────┴──────────┴────────┴──────┴───────────┴──────────┴──────────┴──────────┴──────────┘
```

#### Test Backend API
```bash
# Health check
curl http://localhost:8000/health
# Expected: {"status":"healthy","service":"resume-evaluator-api"}

# Test from external IP (replace with your EC2 IP)
curl http://YOUR_EC2_IP:8000/health
```

#### Test Frontend
```bash
# Test local frontend
curl http://localhost:3000

# Should return HTML content
```

### Step 7: Access Your Application

After successful deployment, your application will be available at:

- **Frontend Web Interface**: `http://YOUR_EC2_IP:3000`
- **Backend API**: `http://YOUR_EC2_IP:8000`
- **API Documentation**: `http://YOUR_EC2_IP:8000/docs`
- **Health Check**: `http://YOUR_EC2_IP:8000/health`

## Complete File Structure

Your deployment should look like this:

```
/home/ec2-user/agentic-resume-evaluator/
├── backend/
│   ├── .env                    # Your environment variables
│   ├── venv/                   # Python virtual environment
│   ├── main.py                 # FastAPI application
│   ├── requirements.txt        # Python dependencies
│   └── ...
├── frontend/
│   ├── .env.local             # Frontend environment variables
│   ├── .next/                 # Built Next.js application
│   ├── package.json           # Node.js dependencies
│   └── ...
├── ecosystem.config.js        # PM2 configuration
├── start-backend.sh          # Backend startup script
└── deploy-ec2-pm2.sh         # Deployment script
```

## PM2 Management Commands

### Essential PM2 Commands
```bash
# Check process status
pm2 status

# View logs (all processes)
pm2 logs

# View specific process logs
pm2 logs resume-evaluator-backend
pm2 logs resume-evaluator-frontend

# Restart all processes
pm2 restart all

# Restart specific process
pm2 restart resume-evaluator-backend

# Stop all processes
pm2 stop all

# Delete all processes
pm2 delete all

# Monitor processes in real-time
pm2 monit

# Reload PM2 configuration
pm2 reload ecosystem.config.js
```

## Troubleshooting Guide

### 1. Backend Not Starting

**Check logs:**
```bash
pm2 logs resume-evaluator-backend --lines 50
```

**Common fixes:**
```bash
# Check Python virtual environment
cd ~/agentic-resume-evaluator/backend
source venv/bin/activate
python --version

# Test backend manually
cd ~/agentic-resume-evaluator
./start-backend.sh
# Press Ctrl+C to stop, then restart with PM2
```

### 2. Frontend Not Loading

**Check if frontend is running:**
```bash
pm2 logs resume-evaluator-frontend --lines 20
```

**Common fixes:**
```bash
# Rebuild frontend
cd ~/agentic-resume-evaluator/frontend
npm run build

# Restart frontend
pm2 restart resume-evaluator-frontend
```

### 3. CORS Errors in Browser

**Symptoms:** Network requests fail with CORS errors

**Fix:** Ensure backend `.env` includes your EC2 IP:
```bash
cd ~/agentic-resume-evaluator/backend
nano .env
# Verify ALLOWED_ORIGINS includes http://YOUR_EC2_IP:3000
pm2 restart resume-evaluator-backend
```

### 4. API Requests Not Working

**Check frontend environment:**
```bash
cd ~/agentic-resume-evaluator/frontend
cat .env.local
# Should show: NEXT_PUBLIC_API_URL=http://YOUR_EC2_IP:8000
```

**Test API directly:**
```bash
curl -X POST http://YOUR_EC2_IP:8000/api/resume/evaluate \
  -F "file=@/path/to/resume.pdf" \
  -F "job_description=Software Developer position"
```

### 5. Security Group Issues

**Verify ports are open:**
- Port 3000 (Frontend)
- Port 8000 (Backend)

**Test port connectivity:**
```bash
# From your local machine
telnet YOUR_EC2_IP 3000
telnet YOUR_EC2_IP 8000
```

## Updating Your Application

### Pull Latest Changes
```bash
cd ~/agentic-resume-evaluator

# Pull updates
git pull origin deployment

# Rebuild frontend if needed
cd frontend && npm run build && cd ..

# Restart processes
pm2 restart all
```

### Update Dependencies
```bash
# Update backend dependencies
cd ~/agentic-resume-evaluator/backend
source venv/bin/activate
pip install -r requirements.txt

# Update frontend dependencies
cd ~/agentic-resume-evaluator/frontend
npm install

# Rebuild and restart
npm run build
cd ..
pm2 restart all
```

## SSL Setup (Optional)

### Install SSL Certificate with Let's Encrypt

```bash
# Install certbot
sudo yum install -y certbot python3-certbot-nginx

# Stop Nginx temporarily
sudo systemctl stop nginx

# Get certificate (replace with your domain)
sudo certbot certonly --standalone -d yourdomain.com

# Update Nginx configuration for HTTPS
sudo nano /etc/nginx/conf.d/resume-evaluator.conf

# Restart Nginx
sudo systemctl start nginx
sudo systemctl enable nginx
```

## Performance Monitoring

### System Resources
```bash
# Check CPU and memory usage
htop

# Check disk usage
df -h

# Check network connections
ss -tulpn
```

### Application Monitoring
```bash
# PM2 monitoring dashboard
pm2 monit

# Check application performance
pm2 info resume-evaluator-backend
pm2 info resume-evaluator-frontend
```

## Backup Strategy

### Create Backup
```bash
# Create backup directory
mkdir -p ~/backups

# Backup application
tar -czf ~/backups/resume-evaluator-$(date +%Y%m%d).tar.gz \
  ~/agentic-resume-evaluator \
  --exclude='node_modules' \
  --exclude='venv' \
  --exclude='.next'

# Backup environment files separately
cp ~/agentic-resume-evaluator/backend/.env ~/backups/
cp ~/agentic-resume-evaluator/frontend/.env.local ~/backups/
```

### Restore from Backup
```bash
# Extract backup
tar -xzf ~/backups/resume-evaluator-YYYYMMDD.tar.gz -C ~/

# Restore environment files
cp ~/backups/.env ~/agentic-resume-evaluator/backend/
cp ~/backups/.env.local ~/agentic-resume-evaluator/frontend/

# Reinstall dependencies and restart
cd ~/agentic-resume-evaluator
./deploy-ec2-pm2.sh
```

## Cost Optimization

### Instance Sizing
- **Development**: t3.small (1 vCPU, 2GB RAM) - ~$15/month
- **Production**: t3.medium (2 vCPU, 4GB RAM) - ~$30/month
- **High Traffic**: t3.large (2 vCPU, 8GB RAM) - ~$60/month

### Storage Optimization
```bash
# Clean up logs
pm2 flush

# Clean npm cache
npm cache clean --force

# Clean unused Docker images (if using Docker)
docker system prune -f
```

## Security Best Practices

### System Security
```bash
# Update system packages
sudo yum update -y

# Configure firewall (if needed)
sudo iptables -A INPUT -p tcp --dport 3000 -j ACCEPT
sudo iptables -A INPUT -p tcp --dport 8000 -j ACCEPT
```

### Application Security
1. **Keep API keys secure** - Never commit to version control
2. **Use HTTPS in production** - Install SSL certificates
3. **Regular updates** - Keep dependencies updated
4. **Monitor logs** - Check for suspicious activity

## Support and Troubleshooting

### Getting Help
1. **Check PM2 logs first**: `pm2 logs`
2. **Verify environment variables** are set correctly
3. **Test API endpoints** individually with curl
4. **Check security group settings** in AWS console
5. **Review browser console** for frontend errors

### Common Error Solutions

**"Module not found" errors:**
```bash
cd ~/agentic-resume-evaluator/backend
source venv/bin/activate
pip install -r requirements.txt
pm2 restart resume-evaluator-backend
```

**"Port already in use" errors:**
```bash
sudo lsof -i :8000
sudo kill -9 <PID>
pm2 restart resume-evaluator-backend
```

**Frontend not updating:**
```bash
cd ~/agentic-resume-evaluator/frontend
rm -rf .next
npm run build
pm2 restart resume-evaluator-frontend
```

---

## Quick Reference

### Environment Variables Template

**Backend (.env):**
```bash
GEMINI_API_KEY=your_gemini_api_key_here
HOST=0.0.0.0
PORT=8000
ENVIRONMENT=production
ALLOWED_ORIGINS=http://localhost:3000,http://YOUR_EC2_IP:3000,http://YOUR_EC2_IP
```

**Frontend (.env.local):**
```bash
NEXT_PUBLIC_API_URL=http://YOUR_EC2_IP:8000
NODE_ENV=production
```

### Essential Commands
```bash
# Deploy from scratch
git clone https://github.com/YasinSaleem/agentic-resume-evaluator.git
cd agentic-resume-evaluator
git checkout deployment
./deploy-ec2-pm2.sh

# Configure environment (replace YOUR_VALUES)
nano backend/.env
nano frontend/.env.local

# Start application
pm2 start ecosystem.config.js --env production
pm2 save

# Check status
pm2 status
pm2 logs

# Access application
http://YOUR_EC2_IP:3000
```

**Remember to replace `YOUR_EC2_IP` and `YOUR_GEMINI_API_KEY` with your actual values!**
