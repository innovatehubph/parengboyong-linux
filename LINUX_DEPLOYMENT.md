# Pareng Boyong - Linux VPS Deployment Guide

## Overview

This guide covers deploying Pareng Boyong on a Linux VPS with Docker, Nginx reverse proxy, and SSL certificate.

**Deployed Instance:** https://ai.innovatehub.site

---

## Prerequisites

- Linux VPS (Ubuntu 22.04+ recommended)
- Docker and Docker Compose installed
- Domain name with DNS access
- Root or sudo access

---

## Quick Start

```bash
# Clone repository
cd /root
git clone https://github.com/innovatehubph/pareng-boyong.git
cd pareng-boyong

# Create data directory
mkdir -p /root/pareng-boyong-data

# Pull Docker image
docker pull agent0ai/agent-zero:latest

# Run container
docker run -d \
  --name pareng-boyong \
  -p 50002:80 \
  -v /root/pareng-boyong-data:/a0 \
  agent0ai/agent-zero:latest

# Container should now be running
docker ps
```

---

## Detailed Installation

### Step 1: Install Docker

```bash
# Update system
apt update && apt upgrade -y

# Install Docker
curl -fsSL https://get.docker.com -o get-docker.sh
sh get-docker.sh

# Start Docker service
systemctl start docker
systemctl enable docker

# Verify installation
docker --version
```

### Step 2: Deploy Pareng Boyong Container

```bash
# Create persistent data directory
mkdir -p /root/pareng-boyong-data

# Pull latest image
docker pull agent0ai/agent-zero:latest

# Run container
docker run -d \
  --name pareng-boyong \
  --restart unless-stopped \
  -p 50002:80 \
  -v /root/pareng-boyong-data:/a0 \
  agent0ai/agent-zero:latest

# Check container status
docker ps

# View logs
docker logs pareng-boyong
```

### Step 3: Configure Environment

Create/edit `/root/pareng-boyong-data/.env`:

```env
# Persistent Runtime ID (auto-generated)
A0_PERSISTENT_RUNTIME_ID=66feda3737f55c5ac3646c00590db860

# Root password (for admin access)
ROOT_PASSWORD=qUhw9Bppw9qgQFs9rvJUyh0CD34T6DwA

# Basic Authentication
BASIC_AUTH_USERNAME=admin
BASIC_AUTH_PASSWORD=innovatehub2026

# Allowed Origins (CORS)
ALLOWED_ORIGINS=*://localhost:*,*://127.0.0.1:*,*://0.0.0.0:*,https://ai.innovatehub.site,http://ai.innovatehub.site
```

Restart container to apply changes:
```bash
docker restart pareng-boyong
```

### Step 4: Apply InnovateHub Rebranding

#### Download InnovateHub Logo

```bash
# Download logo to container's public directory
curl -L https://innovatehub.ph/lovable-uploads/a63fe766-14df-42eb-aa18-cefb71993afa.png \
  -o /root/pareng-boyong-data/webui/public/innovatehub-logo.png
```

#### Update UI Files

**File: `/root/pareng-boyong-data/webui/index.html`**

Find and replace:
```html
<!-- OLD -->
<title>Agent Zero</title>

<!-- NEW -->
<title>Innovatehub AI 'Pareng Boyong'</title>
```

**File: `/root/pareng-boyong-data/webui/login.html`**

Find and replace:
```html
<!-- OLD -->
<title>Login - Agent Zero</title>
<img src="/public/splash.jpg" alt="Agent Zero Logo" class="logo">
<h2>Agent Zero</h2>

<!-- NEW -->
<title>Login - Pareng Boyong</title>
<img src="/public/innovatehub-logo.png" alt="Pareng Boyong Logo" class="logo">
<h2>Pareng Boyong</h2>
```

**File: `/root/pareng-boyong-data/webui/components/welcome/welcome-screen.html`**

Find and replace:
```html
<!-- OLD -->
<img src="./public/darkSymbol.svg" alt="Agent Zero Logo" class="welcome-logo" />
<h1 class="welcome-title">Welcome to Agent Zero</h1>

<!-- NEW -->
<img src="./public/innovatehub-logo.png" alt="Pareng Boyong Logo" class="welcome-logo" />
<h1 class="welcome-title">Welcome to Pareng Boyong</h1>
```

**File: `/root/pareng-boyong-data/webui/components/welcome/welcome-store.js`**

Find and replace:
```javascript
// Update to InnovateHub links
case "website":
  window.open("https://innovatehub.ph", "_blank");
  break;
case "github":
  window.open("https://github.com/innovatehubph/pareng-boyong", "_blank");
  break;
```

No container restart needed - changes apply immediately.

### Step 5: Install and Configure Nginx

```bash
# Install Nginx
apt install nginx -y

# Start and enable Nginx
systemctl start nginx
systemctl enable nginx
```

Create Nginx configuration file:

**File: `/etc/nginx/sites-available/ai.innovatehub.site`**

```nginx
server {
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

    listen 80;
}
```

Enable site:
```bash
ln -s /etc/nginx/sites-available/ai.innovatehub.site /etc/nginx/sites-enabled/
nginx -t
systemctl reload nginx
```

### Step 6: Configure DNS

Update DNS record at your domain provider (e.g., Hostinger):

```
Type: A
Name: ai
Value: [Your VPS IP]
TTL: 300
```

Verify DNS propagation:
```bash
nslookup ai.innovatehub.site
# Should return your VPS IP
```

### Step 7: Obtain SSL Certificate

```bash
# Install Certbot
apt install certbot python3-certbot-nginx -y

# Obtain SSL certificate
certbot --nginx -d ai.innovatehub.site --non-interactive --agree-tos --email admin@innovatehub.site

# Verify auto-renewal
certbot renew --dry-run
```

### Step 8: Verify Deployment

Test HTTP access:
```bash
curl http://localhost:50002
# Should return HTML content
```

Test external HTTPS:
```bash
curl -I https://ai.innovatehub.site
# Should return 302 redirect to /login
```

Open browser: https://ai.innovatehub.site
- ✅ Valid SSL certificate (green padlock)
- ✅ Pareng Boyong login page
- ✅ InnovateHub branding
- ✅ Login with: admin / innovatehub2026

---

## Architecture Diagram

```
Internet User
    ↓
https://ai.innovatehub.site (VPS IP)
    ↓
Nginx (SSL termination + reverse proxy)
    ↓
localhost:50002
    ↓
Docker Container (agent0ai/agent-zero:latest)
    ↓
Pareng Boyong (Flask app on port 80 inside container)
```

---

## Container Management

### View Logs
```bash
docker logs -f pareng-boyong
```

### Restart Container
```bash
docker restart pareng-boyong
```

### Stop Container
```bash
docker stop pareng-boyong
```

### Start Container
```bash
docker start pareng-boyong
```

### Remove Container (keeps data)
```bash
docker stop pareng-boyong
docker rm pareng-boyong
```

### Recreate Container
```bash
docker run -d \
  --name pareng-boyong \
  --restart unless-stopped \
  -p 50002:80 \
  -v /root/pareng-boyong-data:/a0 \
  agent0ai/agent-zero:latest
```

### Update Container
```bash
# Pull latest image
docker pull agent0ai/agent-zero:latest

# Stop and remove old container
docker stop pareng-boyong
docker rm pareng-boyong

# Run new container with same data volume
docker run -d \
  --name pareng-boyong \
  --restart unless-stopped \
  -p 50002:80 \
  -v /root/pareng-boyong-data:/a0 \
  agent0ai/agent-zero:latest
```

---

## Data Persistence

All data is stored in `/root/pareng-boyong-data/`:

```
/root/pareng-boyong-data/
├── .env                    # Configuration
├── memory/                 # Agent memory
├── work/                   # Work files
├── webui/                  # UI files (customizable)
│   ├── index.html
│   ├── login.html
│   ├── public/
│   │   └── innovatehub-logo.png
│   └── components/
│       └── welcome/
│           ├── welcome-screen.html
│           └── welcome-store.js
└── [other data]
```

This data persists even if you remove/recreate the container.

---

## Monitoring

### Check Container Status
```bash
docker ps
# Should show "Up X minutes/hours"
```

### Check Resource Usage
```bash
docker stats pareng-boyong
```

### Check Nginx Status
```bash
systemctl status nginx
```

### Check SSL Certificate Expiry
```bash
certbot certificates
```

---

## Troubleshooting

### Issue: Container won't start

```bash
# Check logs
docker logs pareng-boyong

# Check port availability
netstat -tlnp | grep 50002

# If port in use, stop conflicting service or change port
```

### Issue: Cannot access via domain

```bash
# Check Nginx configuration
nginx -t

# Check Nginx logs
tail -f /var/log/nginx/error.log

# Verify DNS
nslookup ai.innovatehub.site
```

### Issue: SSL certificate expired

```bash
# Renew certificate
certbot renew

# Reload Nginx
systemctl reload nginx
```

### Issue: "Origin not allowed" error

Ensure CORS is configured in `/root/pareng-boyong-data/.env`:
```env
ALLOWED_ORIGINS=*://localhost:*,*://127.0.0.1:*,*://0.0.0.0:*,https://ai.innovatehub.site,http://ai.innovatehub.site
```

Then restart container:
```bash
docker restart pareng-boyong
```

---

## Firewall Configuration

### UFW (Ubuntu Firewall)

```bash
# Allow SSH (important!)
ufw allow 22/tcp

# Allow HTTP and HTTPS
ufw allow 80/tcp
ufw allow 443/tcp

# Enable firewall
ufw enable

# Check status
ufw status
```

### iptables

```bash
# Allow HTTP
iptables -A INPUT -p tcp --dport 80 -j ACCEPT

# Allow HTTPS
iptables -A INPUT -p tcp --dport 443 -j ACCEPT

# Save rules
iptables-save > /etc/iptables/rules.v4
```

---

## Backup and Restore

### Backup

```bash
# Create backup directory
mkdir -p /root/backups

# Backup data directory
tar -czf /root/backups/pareng-boyong-$(date +%Y%m%d).tar.gz /root/pareng-boyong-data/

# Backup Nginx config
cp /etc/nginx/sites-available/ai.innovatehub.site /root/backups/
```

### Restore

```bash
# Stop container
docker stop pareng-boyong

# Restore data
tar -xzf /root/backups/pareng-boyong-YYYYMMDD.tar.gz -C /

# Start container
docker start pareng-boyong
```

---

## Security Best Practices

1. **Use Strong Passwords**
```env
BASIC_AUTH_PASSWORD=your-strong-password-here
ROOT_PASSWORD=another-strong-password
```

2. **Restrict CORS**
```env
ALLOWED_ORIGINS=https://ai.innovatehub.site
```

3. **Keep System Updated**
```bash
apt update && apt upgrade -y
```

4. **Monitor Logs**
```bash
docker logs pareng-boyong --tail 100
tail -f /var/log/nginx/access.log
```

5. **Use Firewall**
```bash
ufw enable
ufw allow 22,80,443/tcp
```

---

## Production Deployment Checklist

- [ ] VPS provisioned with Ubuntu 22.04+
- [ ] Docker installed
- [ ] Container deployed and running
- [ ] .env configured with strong passwords
- [ ] CORS configured for domain
- [ ] InnovateHub rebranding applied
- [ ] Nginx installed and configured
- [ ] DNS A record created
- [ ] SSL certificate obtained
- [ ] Firewall configured
- [ ] HTTPS access verified
- [ ] Login functional
- [ ] Backups configured

---

## Support

- GitHub Repository: https://github.com/innovatehubph/pareng-boyong
- InnovateHub Website: https://innovatehub.ph
- Windows Deployment: See WINDOWS_DEPLOYMENT.md

---

**Deployment Guide Version:** 1.0
**Last Updated:** 2026-01-12
**Maintained by:** InnovateHub Team
