# EC2 Deployment Guide

## Prerequisites

1. **EC2 Instance**: Ubuntu 20.04 LTS or newer (t3.medium or larger recommended)
2. **Security Groups**: Allow inbound traffic on ports 22 (SSH), 80 (HTTP), 443 (HTTPS)
3. **Domain** (optional): For production deployment with SSL
4. **Gemini API Key**: Get from Google AI Studio

## Quick Deployment (Recommended)

### Option 1: Using Docker (Easiest)

1. **Connect to your EC2 instance**:
   ```bash
   ssh -i your-key.pem ubuntu@your-ec2-ip
   ```

2. **Run the deployment script**:
   ```bash
   curl -fsSL https://raw.githubusercontent.com/YasinSaleem/agentic-resume-evaluator/main/deploy-ec2.sh | bash
   ```

3. **Configure environment variables**:
   ```bash
   cd agentic-resume-evaluator
   
   # Add your Gemini API key
   nano backend/.env
   
   # Update API URL for production
   nano frontend/.env
   ```

4. **Restart services**:
   ```bash
   docker-compose restart
   ```

### Option 2: Manual Installation

1. **Clone repository**:
   ```bash
   git clone https://github.com/YasinSaleem/agentic-resume-evaluator.git
   cd agentic-resume-evaluator
   ```

2. **Run setup script**:
   ```bash
   ./deploy-ec2.sh
   ```

## Environment Configuration

### Backend (.env)
```env
GEMINI_API_KEY=your_actual_gemini_api_key_here
HOST=0.0.0.0
PORT=8000
ENVIRONMENT=production
ALLOWED_ORIGINS=https://yourdomain.com,http://localhost:3000
```

### Frontend (.env)
```env
NEXT_PUBLIC_API_URL=https://yourdomain.com
NODE_ENV=production
```

## SSL Setup (Production)

Install SSL certificate using Let's Encrypt:

```bash
sudo apt install certbot python3-certbot-nginx -y
sudo certbot --nginx -d yourdomain.com
```

## Monitoring & Maintenance

### Check Service Status
```bash
# Docker services
docker-compose ps

# View logs
docker-compose logs -f

# Restart services
docker-compose restart
```

### System Services (if using systemd)
```bash
# Check status
sudo systemctl status resume-evaluator-backend
sudo systemctl status resume-evaluator-frontend

# View logs
sudo journalctl -u resume-evaluator-backend -f
```

### Nginx
```bash
# Check status
sudo systemctl status nginx

# Test configuration
sudo nginx -t

# Reload configuration
sudo systemctl reload nginx
```

## Troubleshooting

### Common Issues

1. **Port 8000 already in use**:
   ```bash
   sudo lsof -i :8000
   sudo kill -9 <PID>
   ```

2. **Permission denied for Docker**:
   ```bash
   sudo usermod -aG docker $USER
   # Log out and log back in
   ```

3. **Frontend not connecting to backend**:
   - Check `NEXT_PUBLIC_API_URL` in frontend/.env
   - Verify backend is running on port 8000
   - Check security group allows traffic on port 80/443

4. **Gemini API errors**:
   - Verify API key is correct in backend/.env
   - Check API quotas and billing

### Performance Optimization

1. **Scale with Docker Compose**:
   ```yaml
   services:
     backend:
       deploy:
         replicas: 2
   ```

2. **Use PM2 for Node.js** (alternative to Docker):
   ```bash
   npm install -g pm2
   pm2 start npm --name "frontend" -- start
   ```

3. **Configure Nginx caching**:
   ```nginx
   location ~* \.(js|css|png|jpg|jpeg|gif|ico|svg)$ {
       expires 1y;
       add_header Cache-Control "public, immutable";
   }
   ```

## Security Considerations

1. **Update CORS origins** in backend/main.py
2. **Use environment variables** for sensitive data
3. **Enable HTTPS** with SSL certificates
4. **Regular updates**: 
   ```bash
   sudo apt update && sudo apt upgrade -y
   ```
5. **Firewall setup**:
   ```bash
   sudo ufw enable
   sudo ufw allow ssh
   sudo ufw allow 'Nginx Full'
   ```

## Cost Optimization

- Use t3.small for low traffic (1 vCPU, 2GB RAM)
- Use t3.medium for moderate traffic (2 vCPU, 4GB RAM)
- Consider spot instances for development
- Set up CloudWatch alarms for cost monitoring
