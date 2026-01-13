# Pareng Boyong - Windows Server Deployment Guide

## Overview

This guide covers deploying Pareng Boyong on Windows Server with HTTPS access via VPS reverse proxy.

**Architecture:** Windows runs Pareng Boyong locally, Linux VPS handles SSL and public access.

---

## Prerequisites

- Windows Server (Windows 10/11 or Windows Server 2019/2022)
- Python 3.12+
- Tailscale account (for VPN connectivity)
- Linux VPS for reverse proxy (optional, but recommended if ports blocked)
- Domain name with DNS access

---

## Installation Steps

### Step 1: Install Python

Download and install Python 3.12+ from https://python.org

```powershell
# Verify installation
python --version
```

### Step 2: Clone Repository

```powershell
# Navigate to installation directory
cd D:\

# Create Boyong directory
mkdir Boyong
cd Boyong

# Clone repository
git clone https://github.com/innovatehubph/pareng-boyong.git agent-zero
cd agent-zero
```

### Step 3: Install Dependencies

```powershell
# Install required packages
pip install -r requirements.txt
```

### Step 4: Configure Environment

Create `.env` file in `D:\Boyong\agent-zero\`:

```env
# AI Provider API Keys
API_KEY_ANTHROPIC=your-anthropic-api-key-here
API_KEY_OPENAI=your-openai-api-key-here
API_KEY_GOOGLE=your-google-api-key-here

# Working Directory
WORK_DIR=D:/

# Web UI Configuration
WEB_UI_HOST=0.0.0.0
WEB_UI_PORT=5000

# Authentication
AUTH_LOGIN=admin
AUTH_PASSWORD=innovatehub2026

# CORS Configuration
ALLOWED_ORIGINS=*://localhost:*,*://127.0.0.1:*,*://0.0.0.0:*,https://win-ai.innovatehub.site,http://win-ai.innovatehub.site

# Runtime ID (auto-generated)
A0_PERSISTENT_RUNTIME_ID=c23e57e6279863726dffb6c2789673db
DEFAULT_USER_UTC_OFFSET_MINUTES=0
```

### Step 5: Apply InnovateHub Rebranding

#### Download InnovateHub Logo

```powershell
# Download logo
Invoke-WebRequest -Uri "https://innovatehub.ph/lovable-uploads/a63fe766-14df-42eb-aa18-cefb71993afa.png" -OutFile "D:\Boyong\agent-zero\webui\public\innovatehub-logo.png"
```

#### Update UI Files

**File: `webui\index.html`**

Find and replace:
```html
<!-- OLD -->
<title>Agent Zero</title>

<!-- NEW -->
<title>Innovatehub AI 'Pareng Boyong'</title>
```

**File: `webui\login.html`**

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

**File: `webui\components\welcome\welcome-screen.html`**

Find and replace:
```html
<!-- OLD -->
<img src="./public/darkSymbol.svg" alt="Agent Zero Logo" class="welcome-logo" />
<h1 class="welcome-title">Welcome to Agent Zero</h1>

<!-- NEW -->
<img src="./public/innovatehub-logo.png" alt="Pareng Boyong Logo" class="welcome-logo" />
<h1 class="welcome-title">Welcome to Pareng Boyong</h1>
```

**File: `webui\components\welcome\welcome-store.js`**

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

### Step 6: Start Pareng Boyong

```powershell
cd D:\Boyong\agent-zero
python run_ui.py
```

**Expected output:**
```
* Running on http://0.0.0.0:5000
* Running on http://192.168.x.x:5000
```

### Step 7: Test Local Access

Open browser: http://localhost:5000

- ✅ Should show Pareng Boyong login page
- ✅ InnovateHub logo visible
- ✅ Login with: admin / innovatehub2026

---

## Public Access Setup (If Ports Blocked)

If your ISP/router blocks ports 80/443, use VPS reverse proxy:

### Install Tailscale (VPN)

```powershell
# Download and install Tailscale
# Visit: https://tailscale.com/download/windows

# After installation, connect with auth key
tailscale up --auth-key=your-auth-key-here

# Check status
tailscale status
# Note your Tailscale IP (e.g., 100.108.74.84)
```

### Configure DNS

Update your domain DNS record:

**On Hostinger (or your DNS provider):**
```
Type: A
Name: win-ai
Value: [VPS IP Address] (NOT Windows server IP)
TTL: 300
```

This routes public traffic through the VPS, which will proxy to your Windows server via Tailscale.

---

## VPS Reverse Proxy Setup

On your Linux VPS, configure Nginx reverse proxy:

**File: `/etc/nginx/sites-available/win-ai.innovatehub.site`**

```nginx
server {
    server_name win-ai.innovatehub.site;

    location /.well-known/acme-challenge/ {
        root /var/www/html;
    }

    location / {
        # Proxy to Windows server via Tailscale
        proxy_pass http://[WINDOWS_TAILSCALE_IP]:5000;
        proxy_http_version 1.1;

        # WebSocket support
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";

        # Headers
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;

        # Timeouts
        proxy_connect_timeout 60s;
        proxy_send_timeout 60s;
        proxy_read_timeout 60s;

        # Buffering
        proxy_buffering off;
    }

    listen 80;
}
```

Enable site and obtain SSL:
```bash
ln -s /etc/nginx/sites-available/win-ai.innovatehub.site /etc/nginx/sites-enabled/
nginx -t
systemctl reload nginx
certbot --nginx -d win-ai.innovatehub.site
```

---

## Architecture Diagram

```
Internet User
    ↓
https://win-ai.innovatehub.site (VPS IP)
    ↓
Linux VPS (Nginx)
  - SSL termination
  - Reverse proxy
    ↓
Tailscale VPN (encrypted)
    ↓
Windows Server (Tailscale IP)
  - Pareng Boyong on port 5000
  - Behind firewall (secure)
```

---

## Maintenance

### Daily Operation

Pareng Boyong runs continuously. If you reboot Windows:

```powershell
cd D:\Boyong\agent-zero
python run_ui.py
```

### Check Status

```powershell
# Check if Pareng Boyong is running
netstat -ano | findstr :5000

# Check Tailscale connection
tailscale status
```

### Update Configuration

Edit `.env` file, then restart:

```powershell
# Stop (Ctrl+C in terminal)
# Or:
Stop-Process -Name python -Force

# Restart
python run_ui.py
```

---

## Troubleshooting

### Issue: Port 5000 already in use

```powershell
# Find process using port 5000
netstat -ano | findstr :5000

# Stop the process (note the PID)
Stop-Process -Id [PID] -Force

# Restart Pareng Boyong
python run_ui.py
```

### Issue: Import errors

```powershell
# Reinstall dependencies
pip install -r requirements.txt --force-reinstall
```

### Issue: Can't access from network

```powershell
# Check Windows Firewall
New-NetFirewallRule -Name "Pareng Boyong" -DisplayName "Pareng Boyong Port 5000" -Direction Inbound -Action Allow -Protocol TCP -LocalPort 5000

# Or disable firewall temporarily for testing
Set-NetFirewallProfile -Profile Domain,Public,Private -Enabled False
```

### Issue: Tailscale connection problems

```powershell
# Restart Tailscale
Restart-Service Tailscale

# Re-authenticate
tailscale up
```

---

## Security Considerations

### Advantages of VPS Proxy Architecture

- ✅ Windows server not exposed to internet
- ✅ SSL handled by VPS
- ✅ ISP firewall becomes security feature
- ✅ Only accessible via Tailscale VPN
- ✅ Can add rate limiting on VPS

### Additional Security

**Strong passwords:**
```env
AUTH_PASSWORD=use-strong-password-here
```

**Restrict CORS:**
```env
ALLOWED_ORIGINS=https://win-ai.innovatehub.site
```

**Keep Python updated:**
```powershell
python -m pip install --upgrade pip
pip install -r requirements.txt --upgrade
```

---

## Production Deployment Checklist

- [ ] Python 3.12+ installed
- [ ] Repository cloned
- [ ] Dependencies installed
- [ ] .env configured with API keys
- [ ] InnovateHub rebranding applied
- [ ] Strong authentication password set
- [ ] CORS configured for your domain
- [ ] Tailscale installed and connected
- [ ] VPS reverse proxy configured
- [ ] DNS pointing to VPS
- [ ] SSL certificate obtained
- [ ] Local access works (http://localhost:5000)
- [ ] Public access works (https://win-ai.innovatehub.site)
- [ ] Login functional
- [ ] AI model responding

---

## Support

- GitHub Repository: https://github.com/innovatehubph/pareng-boyong
- InnovateHub Website: https://innovatehub.ph
- Linux VPS Deployment: See LINUX_DEPLOYMENT.md

---

**Deployment Guide Version:** 1.0
**Last Updated:** 2026-01-12
**Maintained by:** InnovateHub Team
