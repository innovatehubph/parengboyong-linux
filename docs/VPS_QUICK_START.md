# Pareng Boyong - VPS Quick Start Guide

## 5-Minute Setup for Linux VPS

This is a condensed version for experienced users. For detailed instructions, see [VPS_INSTALLATION_GUIDE.md](VPS_INSTALLATION_GUIDE.md).

---

## Prerequisites

- Linux VPS (Ubuntu 20.04+)
- Root access
- Docker installed
- Domain configured (optional)

---

## Quick Installation

### 1. Clone Repository

```bash
cd /root
git clone https://github.com/innovatehubph/pareng-boyong.git
cd pareng-boyong
```

### 2. Pull Docker Image

```bash
docker pull agent0ai/agent-zero:latest
```

### 3. Create Data Directory

```bash
mkdir -p /root/pareng-boyong-data
```

### 4. Run Container

```bash
docker run -d \
  --name pareng-boyong \
  -p 50002:80 \
  -v /root/pareng-boyong-data:/a0 \
  agent0ai/agent-zero:latest
```

### 5. Apply Rebranding

Wait 2 minutes for files to copy, then:

```bash
sed -i 's/<title>Agent Zero<\/title>/<title>Innovatehub AI '\''Pareng Boyong'\''<\/title>/g' /root/pareng-boyong-data/webui/index.html
docker restart pareng-boyong
```

### 6. Test Installation

```bash
# Wait 15 seconds
sleep 15

# Test
curl -s http://localhost:50002 | grep -o "<title>.*</title>"
```

**Expected:** `<title>Innovatehub AI 'Pareng Boyong'</title>`

---

## Setup Domain with HTTPS (Optional)

### 1. Configure DNS

In your DNS provider:
- Type: A Record
- Name: ai (or your subdomain)
- Value: Your VPS IP

### 2. Install Nginx & Certbot

```bash
apt update
apt install -y nginx certbot python3-certbot-nginx
```

### 3. Create Nginx Config

```bash
cat > /etc/nginx/sites-available/ai.innovatehub.site << 'EOF'
server {
    listen 80;
    listen [::]:80;
    server_name ai.innovatehub.site;

    location /.well-known/acme-challenge/ {
        root /var/www/html;
    }

    location / {
        proxy_pass http://localhost:50002;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_connect_timeout 60s;
        proxy_send_timeout 60s;
        proxy_read_timeout 60s;
    }
}
EOF
```

Replace `ai.innovatehub.site` with your domain.

### 4. Enable Site & Get SSL

```bash
ln -s /etc/nginx/sites-available/ai.innovatehub.site /etc/nginx/sites-enabled/
nginx -t
systemctl restart nginx

certbot --nginx -d ai.innovatehub.site --non-interactive --agree-tos --email admin@innovatehub.site --redirect
```

### 5. Test HTTPS

```bash
curl -I https://ai.innovatehub.site
```

---

## Access Your Installation

### Without Domain
- http://YOUR_VPS_IP:50002

### With Domain
- https://ai.innovatehub.site

---

## Essential Commands

```bash
# View logs
docker logs pareng-boyong -f

# Restart
docker restart pareng-boyong

# Stop
docker stop pareng-boyong

# Start
docker start pareng-boyong

# Shell access
docker exec -it pareng-boyong bash

# Check Nginx
systemctl status nginx

# SSL certificates
certbot certificates
```

---

## Add API Keys

```bash
nano /root/pareng-boyong-data/.env
# Add your keys, then:
docker restart pareng-boyong
```

---

## Troubleshooting

### Container won't start
```bash
docker logs pareng-boyong
docker restart pareng-boyong
```

### Port already in use
```bash
# Change port 50002 to 50003 (or any free port)
docker rm pareng-boyong
docker run -d --name pareng-boyong -p 50003:80 -v /root/pareng-boyong-data:/a0 agent0ai/agent-zero:latest
```

### DNS not resolving
```bash
nslookup your-domain.com
# Wait 5-30 minutes for propagation
```

### Certbot fails
```bash
# Ensure DNS is propagated first
nslookup your-domain.com

# Ensure port 80 is open
ufw allow 80/tcp

# Try again
certbot --nginx -d your-domain.com
```

---

## Firewall Setup

```bash
ufw allow 22/tcp   # SSH (IMPORTANT!)
ufw allow 80/tcp   # HTTP
ufw allow 443/tcp  # HTTPS
ufw enable
```

---

## Automatic Backups

```bash
# Create backup script
cat > /root/backup-pareng-boyong.sh << 'EOF'
#!/bin/bash
BACKUP_DIR="/root/backups"
DATE=$(date +%Y%m%d_%H%M%S)
mkdir -p $BACKUP_DIR
tar -czf $BACKUP_DIR/pareng-boyong-data-$DATE.tar.gz /root/pareng-boyong-data
ls -t $BACKUP_DIR/pareng-boyong-data-*.tar.gz | tail -n +8 | xargs -r rm
echo "Backup completed: $DATE"
EOF

chmod +x /root/backup-pareng-boyong.sh

# Daily backup at 2 AM
(crontab -l 2>/dev/null; echo "0 2 * * * /root/backup-pareng-boyong.sh") | crontab -
```

---

## Update Container

```bash
docker stop pareng-boyong
docker rm pareng-boyong
docker pull agent0ai/agent-zero:latest
docker run -d --name pareng-boyong -p 50002:80 -v /root/pareng-boyong-data:/a0 agent0ai/agent-zero:latest
```

---

**Total Setup Time:** ~5-10 minutes (without domain) or ~15-20 minutes (with domain)

For detailed step-by-step instructions, see: [VPS_INSTALLATION_GUIDE.md](VPS_INSTALLATION_GUIDE.md)

---

*Last Updated: 2026-01-12*
