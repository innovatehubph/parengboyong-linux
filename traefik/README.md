# Traefik Reverse Proxy for Pareng Boyong

## Overview
This Traefik setup provides:
- Automatic HTTPS with Let's Encrypt SSL certificates
- Reverse proxy from `win-ai.innovatehub.site` to `localhost:5000`
- HTTP to HTTPS redirection
- Traefik dashboard on port 8081

## Architecture

```
Internet
    ↓
win-ai.innovatehub.site (130.105.71.58)
    ↓
Traefik (Docker Container)
    ├─ Port 80  → Redirect to HTTPS
    ├─ Port 443 → SSL/TLS termination
    └─ Port 8081 → Traefik Dashboard
    ↓
localhost:5000
    ↓
Pareng Boyong Flask App
```

## Quick Start

### 1. Start Pareng Boyong (if not already running)
```bash
cd D:\Boyong\agent-zero
python run_ui.py
```

### 2. Start Traefik
```bash
cd D:\Boyong\traefik
docker-compose up -d
```

### 3. Check Status
```bash
docker-compose ps
docker-compose logs -f traefik
```

### 4. Access Points
- **Pareng Boyong:** https://win-ai.innovatehub.site
- **Traefik Dashboard:** http://localhost:9090

## Configuration Files

### docker-compose.yml
- Defines Traefik container
- Maps ports 80, 443, and 8081
- Connects to Docker socket
- Sets up network

### config/traefik.yml
- Main Traefik configuration
- Entry points (HTTP, HTTPS)
- Let's Encrypt settings
- Docker provider configuration

### config/dynamic.yml
- Dynamic routing rules
- Routes `win-ai.innovatehub.site` to `localhost:5000`
- SSL certificate configuration

### letsencrypt/acme.json
- Stores Let's Encrypt certificates
- Auto-renewed by Traefik
- Permissions: 600 (required)

## Commands

### Start Traefik
```bash
cd D:\Boyong\traefik
docker-compose up -d
```

### Stop Traefik
```bash
docker-compose down
```

### View Logs
```bash
docker-compose logs -f
```

### Restart Traefik
```bash
docker-compose restart
```

### Check Status
```bash
docker-compose ps
docker ps | grep traefik
```

## Troubleshooting

### SSL Certificate Not Working
1. Check logs: `docker-compose logs traefik`
2. Verify DNS: `nslookup win-ai.innovatehub.site`
3. Ensure ports 80 and 443 are open in firewall
4. Let's Encrypt needs port 80 for HTTP challenge

### Can't Access Website
1. Check if Pareng Boyong is running: `netstat -an | grep :5000`
2. Check Traefik logs: `docker-compose logs traefik`
3. Verify routing in Traefik dashboard: http://localhost:8081

### Port Already in Use
```bash
# Find what's using port 80
netstat -ano | grep :80

# Stop the service or change Traefik port
```

## Security Notes

- Traefik dashboard is currently accessible without authentication
- To secure it, add basicAuth middleware
- SSL certificates auto-renew every 60 days
- Change email in traefik.yml to your actual email

## Firewall Configuration

Make sure these ports are open:
- **Port 80:** HTTP (needed for Let's Encrypt)
- **Port 443:** HTTPS (main traffic)
- **Port 9090:** Traefik dashboard (optional, can be closed externally)

### Windows Firewall Commands
```powershell
# Allow port 80
netsh advfirewall firewall add rule name="HTTP" dir=in action=allow protocol=TCP localport=80

# Allow port 443
netsh advfirewall firewall add rule name="HTTPS" dir=in action=allow protocol=TCP localport=443
```

## Updating Configuration

After changing `dynamic.yml`:
```bash
# Traefik watches for changes automatically
# Or restart:
docker-compose restart
```

After changing `traefik.yml` or `docker-compose.yml`:
```bash
docker-compose down
docker-compose up -d
```

## Let's Encrypt Rate Limits

- 50 certificates per registered domain per week
- Use staging environment for testing
- Production certs included in this config

---

**Project:** Innovatehub AI - Pareng Boyong
**Domain:** win-ai.innovatehub.site
**Server IP:** 130.105.71.58
**Backend:** localhost:5000
