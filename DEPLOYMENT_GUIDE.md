# 🚀 Deployment Guide - Agentic AI System

Complete guide for deploying the Agentic AI system to production.

## 📋 Pre-Deployment Checklist

- [ ] Database is accessible from production server
- [ ] OpenAI API key is valid and has sufficient credits
- [ ] SSL certificates are configured
- [ ] Firewall rules are set up
- [ ] Environment variables are configured
- [ ] Backup strategy is in place

## 🐳 Docker Deployment (Recommended)

### Step 1: Create Dockerfile

Create `backend/Dockerfile`:

```dockerfile
FROM python:3.11-slim

WORKDIR /app

# Install system dependencies
RUN apt-get update && apt-get install -y \
    gcc \
    default-libmysqlclient-dev \
    pkg-config \
    && rm -rf /var/lib/apt/lists/*

# Copy requirements
COPY requirements.txt .

# Install Python dependencies
RUN pip install --no-cache-dir -r requirements.txt

# Copy application code
COPY . .

# Expose port
EXPOSE 8000

# Run application
CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000"]
```

### Step 2: Create docker-compose.yml

```yaml
version: '3.8'

services:
  backend:
    build: ./backend
    ports:
      - "8000:8000"
    environment:
      - DATABASE_URL=${DATABASE_URL}
      - OPENAI_API_KEY=${OPENAI_API_KEY}
      - ENVIRONMENT=production
      - DEBUG=False
    env_file:
      - ./backend/.env
    restart: unless-stopped
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:8000/api/v1/health"]
      interval: 30s
      timeout: 10s
      retries: 3

  frontend:
    build: ./frontend
    ports:
      - "3000:3000"
    environment:
      - REACT_APP_API_URL=http://backend:8000
    depends_on:
      - backend
    restart: unless-stopped
```

### Step 3: Deploy with Docker

```bash
# Build and start services
docker-compose up -d

# View logs
docker-compose logs -f

# Stop services
docker-compose down
```

## 🖥️ Traditional Server Deployment

### Step 1: Server Setup (Ubuntu 20.04+)

```bash
# Update system
sudo apt update && sudo apt upgrade -y

# Install Python and dependencies
sudo apt install python3.11 python3.11-venv python3-pip nginx -y

# Install MySQL client
sudo apt install default-libmysqlclient-dev pkg-config -y
```

### Step 2: Application Setup

```bash
# Create application directory
sudo mkdir -p /var/www/agentic-ai
cd /var/www/agentic-ai

# Clone or copy your code
# git clone <your-repo> .

# Create virtual environment
python3.11 -m venv venv
source venv/bin/activate

# Install dependencies
pip install -r backend/requirements.txt

# Install production server
pip install gunicorn
```

### Step 3: Configure Environment

```bash
# Create .env file
nano backend/.env

# Add production settings
DATABASE_URL=mysql+pymysql://user:pass@db-server:3306/pms_dev_nmg_90
OPENAI_API_KEY=sk-your-production-key
ENVIRONMENT=production
DEBUG=False
SECRET_KEY=<generate-secure-key>
```

### Step 4: Create Systemd Service

Create `/etc/systemd/system/agentic-ai.service`:

```ini
[Unit]
Description=Agentic AI FastAPI Application
After=network.target

[Service]
Type=notify
User=www-data
Group=www-data
WorkingDirectory=/var/www/agentic-ai/backend
Environment="PATH=/var/www/agentic-ai/venv/bin"
ExecStart=/var/www/agentic-ai/venv/bin/gunicorn main:app \
    -w 4 \
    -k uvicorn.workers.UvicornWorker \
    --bind 0.0.0.0:8000 \
    --access-logfile /var/log/agentic-ai/access.log \
    --error-logfile /var/log/agentic-ai/error.log

Restart=always
RestartSec=10

[Install]
WantedBy=multi-user.target
```

### Step 5: Configure Nginx

Create `/etc/nginx/sites-available/agentic-ai`:

```nginx
server {
    listen 80;
    server_name your-domain.com;

    # Redirect to HTTPS
    return 301 https://$server_name$request_uri;
}

server {
    listen 443 ssl http2;
    server_name your-domain.com;

    # SSL Configuration
    ssl_certificate /etc/ssl/certs/your-cert.pem;
    ssl_certificate_key /etc/ssl/private/your-key.pem;

    # Security headers
    add_header X-Frame-Options "SAMEORIGIN" always;
    add_header X-Content-Type-Options "nosniff" always;
    add_header X-XSS-Protection "1; mode=block" always;

    # API Backend
    location /api/ {
        proxy_pass http://localhost:8000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_cache_bypass $http_upgrade;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }

    # Frontend (if serving static files)
    location / {
        root /var/www/agentic-ai/frontend/build;
        try_files $uri $uri/ /index.html;
    }
}
```

### Step 6: Start Services

```bash
# Create log directory
sudo mkdir -p /var/log/agentic-ai
sudo chown www-data:www-data /var/log/agentic-ai

# Enable and start service
sudo systemctl enable agentic-ai
sudo systemctl start agentic-ai

# Enable nginx site
sudo ln -s /etc/nginx/sites-available/agentic-ai /etc/nginx/sites-enabled/
sudo nginx -t
sudo systemctl restart nginx

# Check status
sudo systemctl status agentic-ai
```

## 🔒 Security Best Practices

### 1. Environment Variables
```bash
# Never commit .env files
# Use secrets management (AWS Secrets Manager, HashiCorp Vault)
```

### 2. Database Security
```bash
# Use read-only database user for queries
# Implement connection pooling
# Enable SSL for database connections
```

### 3. API Security
```python
# Add rate limiting
from slowapi import Limiter
from slowapi.util import get_remote_address

limiter = Limiter(key_func=get_remote_address)
app.state.limiter = limiter

@app.post("/api/v1/agentic/query")
@limiter.limit("10/minute")
async def process_query(...):
    ...
```

### 4. CORS Configuration
```python
# Restrict CORS to specific domains
CORS_ORIGINS = [
    "https://your-production-domain.com"
]
```

## 📊 Monitoring

### Application Logs
```bash
# View application logs
sudo journalctl -u agentic-ai -f

# View nginx logs
sudo tail -f /var/log/nginx/access.log
sudo tail -f /var/log/nginx/error.log
```

### Health Monitoring
```bash
# Set up health check cron job
*/5 * * * * curl -f http://localhost:8000/api/v1/health || echo "Health check failed"
```

## 🔄 Updates and Maintenance

### Update Application
```bash
cd /var/www/agentic-ai
git pull origin main
source venv/bin/activate
pip install -r backend/requirements.txt --upgrade
sudo systemctl restart agentic-ai
```

### Database Backups
```bash
# Automated backup script
mysqldump -u user -p pms_dev_nmg_90 > backup_$(date +%Y%m%d).sql
```

## 🐛 Troubleshooting

### Service won't start
```bash
# Check logs
sudo journalctl -u agentic-ai -n 50

# Check permissions
ls -la /var/www/agentic-ai

# Test manually
cd /var/www/agentic-ai/backend
source ../venv/bin/activate
python main.py
```

### Database connection issues
```bash
# Test connection
mysql -h db-server -u user -p pms_dev_nmg_90

# Check firewall
sudo ufw status
```

## 📈 Performance Optimization

1. **Enable caching** for frequent queries
2. **Use connection pooling** for database
3. **Implement CDN** for static assets
4. **Enable gzip compression** in Nginx
5. **Monitor and optimize** slow queries

## ✅ Post-Deployment Verification

```bash
# Test health endpoint
curl https://your-domain.com/api/v1/health

# Test query endpoint
curl -X POST https://your-domain.com/api/v1/agentic/query \
  -H "Content-Type: application/json" \
  -d '{"query": "Show me all active workflows"}'
```

## 📞 Support

For deployment issues, contact DevOps team or refer to internal documentation.

