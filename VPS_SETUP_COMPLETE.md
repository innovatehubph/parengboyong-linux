# Pareng Boyong VPS Setup - Complete

## 🎉 Installation Summary

**Pareng Boyong** (Innovatehub AI's Agent Zero) has been successfully installed and configured on your VPS!

---

## 📍 Access Information

### Production URL (HTTPS)
**https://ai.innovatehub.site**

- ✅ SSL Certificate: Valid (Let's Encrypt)
- ✅ Auto-renewal: Configured (renews every 90 days)
- ✅ HTTP to HTTPS: Automatic redirect enabled
- ✅ Rebranded: "Innovatehub AI 'Pareng Boyong'"

### Local Access
- **Direct Container Access:** http://localhost:50002
- **Nginx Status:** Active and running

---

## 🖥️ Server Details

**VPS IP Address:** 37.44.244.226
**Domain:** ai.innovatehub.site
**DNS Provider:** Hostinger (configured)

---

## 📂 Directory Structure

```
/root/
├── pareng-boyong/              # Git repository (source code)
│   ├── .git/                   # Git version control
│   ├── webui/                  # Web UI source files
│   ├── agents/                 # Agent definitions
│   ├── prompts/                # System prompts
│   └── docker/                 # Docker configurations
│
└── pareng-boyong-data/         # Active data (Docker volume)
    ├── .env                    # API keys and configuration
    ├── webui/                  # Active web UI (REBRANDED)
    │   └── index.html          # Modified with "Pareng Boyong" title
    ├── memory/                 # Agent's memory storage
    ├── knowledge/              # Knowledge base
    ├── logs/                   # Application logs
    ├── tmp/                    # Temporary files & settings
    └── prompts/                # Custom prompts
```

---

## 🐳 Docker Configuration

**Container Name:** `pareng-boyong`
**Image:** `agent0ai/agent-zero:latest`
**Port Mapping:** 50002:80 (host:container)
**Volume Mount:** `/root/pareng-boyong-data:/a0`
**Status:** Running

---

## 🔧 Nginx Reverse Proxy

**Configuration File:** `/etc/nginx/sites-available/ai.innovatehub.site`

**Features:**
- Reverse proxy to localhost:50002
- WebSocket support enabled
- SSL/TLS termination
- HTTP to HTTPS redirect
- Proper headers forwarding

---

## 🔒 SSL/TLS Certificate

**Provider:** Let's Encrypt
**Certificate Location:** `/etc/letsencrypt/live/ai.innovatehub.site/`
**Expiration:** 2026-04-12 (90 days from now)
**Auto-renewal:** Configured via systemd timer

**Certbot Timer Status:**
```bash
systemctl status certbot.timer
```

---

## 🚀 Useful Commands

### Docker Management

```bash
# View logs
docker logs pareng-boyong

# Follow logs in real-time
docker logs -f pareng-boyong

# Restart container
docker restart pareng-boyong

# Stop container
docker stop pareng-boyong

# Start container
docker start pareng-boyong

# Access container shell
docker exec -it pareng-boyong bash

# View container stats
docker stats pareng-boyong
```

### Nginx Management

```bash
# Restart Nginx
systemctl restart nginx

# Check Nginx status
systemctl status nginx

# Test configuration
nginx -t

# View error logs
tail -f /var/log/nginx/error.log

# View access logs
tail -f /var/log/nginx/access.log
```

### SSL Certificate Management

```bash
# List certificates
certbot certificates

# Renew certificate manually
certbot renew

# Test renewal process
certbot renew --dry-run
```

---

## ⚙️ Configuration Files

### Environment Variables
**Location:** `/root/pareng-boyong-data/.env`

To add API keys:
```bash
docker exec -it pareng-boyong vi /a0/.env
# or edit directly:
nano /root/pareng-boyong-data/.env
```

After editing, restart the container:
```bash
docker restart pareng-boyong
```

### Nginx Configuration
**Location:** `/etc/nginx/sites-available/ai.innovatehub.site`

After editing:
```bash
nginx -t  # Test configuration
systemctl restart nginx  # Apply changes
```

---

## 🎨 Rebranding Applied

✅ **Page Title:** Changed from "Agent Zero" to "Innovatehub AI 'Pareng Boyong'"
✅ **File Modified:** `/root/pareng-boyong-data/webui/index.html`

### Additional Rebranding Options

To further customize:

1. **Logo:** Place logo at `/root/pareng-boyong-data/webui/public/logo.png`
2. **CSS Styles:** Edit `/root/pareng-boyong-data/webui/index.css`
3. **Favicon:** Replace `/root/pareng-boyong-data/webui/public/favicon.svg`

After making changes, restart the container:
```bash
docker restart pareng-boyong
```

---

## 🔄 Updating Pareng Boyong

### Method 1: Docker Image Update
```bash
# Stop and remove current container
docker stop pareng-boyong
docker rm pareng-boyong

# Pull latest image
docker pull agent0ai/agent-zero:latest

# Recreate container with same settings
docker run -d --name pareng-boyong \
  -p 50002:80 \
  -v /root/pareng-boyong-data:/a0 \
  agent0ai/agent-zero:latest
```

### Method 2: Git Repository Update
```bash
cd /root/pareng-boyong
git pull origin main
```

---

## 🛡️ Security Considerations

### Firewall Status
Check if firewall is configured:
```bash
ufw status
```

If needed, allow necessary ports:
```bash
ufw allow 80/tcp    # HTTP
ufw allow 443/tcp   # HTTPS
ufw enable
```

### API Keys
- Store sensitive API keys in `/root/pareng-boyong-data/.env`
- Never commit `.env` to git
- Restrict file permissions: `chmod 600 /root/pareng-boyong-data/.env`

---

## 📊 Monitoring

### Check if services are running
```bash
# Docker container
docker ps | grep pareng-boyong

# Nginx
systemctl status nginx

# SSL certificate
certbot certificates
```

### View resource usage
```bash
# Container resources
docker stats pareng-boyong --no-stream

# System resources
htop  # or: top
```

---

## 🔧 Troubleshooting

### Issue: Cannot access ai.innovatehub.site

**Check 1: DNS**
```bash
nslookup ai.innovatehub.site
# Should return: 37.44.244.226
```

**Check 2: Container**
```bash
docker ps | grep pareng-boyong
# Container should be running
```

**Check 3: Nginx**
```bash
systemctl status nginx
# Should be active (running)
```

**Check 4: Port**
```bash
netstat -tulpn | grep :50002
# Should show docker-proxy listening
```

### Issue: SSL certificate error

**Check certificate:**
```bash
certbot certificates
```

**Renew certificate:**
```bash
certbot renew --force-renewal
systemctl restart nginx
```

### Issue: Container not starting

**View logs:**
```bash
docker logs pareng-boyong
```

**Recreate container:**
```bash
docker stop pareng-boyong
docker rm pareng-boyong
docker run -d --name pareng-boyong \
  -p 50002:80 \
  -v /root/pareng-boyong-data:/a0 \
  agent0ai/agent-zero:latest
```

---

## 📝 Notes

- **Existing Container:** There's another Agent Zero container running on port 50001
- **Data Persistence:** All data is stored in `/root/pareng-boyong-data/`
- **Automatic Backups:** Consider setting up regular backups of the data directory
- **Certificate Renewal:** Automatic via systemd timer (no manual action needed)

---

## 🔗 Useful Links

- **Pareng Boyong Repository:** https://github.com/innovatehubph/pareng-boyong
- **InnovateHub Website:** https://innovatehub.ph
- **Let's Encrypt:** https://letsencrypt.org
- **Nginx Documentation:** https://nginx.org/en/docs/

---

## ✅ Verification Checklist

- [x] DNS configured and resolving correctly
- [x] Docker container running
- [x] Nginx reverse proxy configured
- [x] SSL certificate installed and valid
- [x] HTTPS accessible from internet
- [x] HTTP to HTTPS redirect working
- [x] Page title rebranded
- [x] WebSocket support enabled
- [x] Auto-renewal configured

---

**Setup Completed:** 2026-01-12
**Domain:** ai.innovatehub.site
**VPS IP:** 37.44.244.226
**Container:** pareng-boyong

---

*For support or questions, contact InnovateHub Inc. at https://innovatehub.ph*
