# Nginx Reverse Proxy Setup for Pareng Boyong

## Overview

**Architecture:**
```
Internet → Port 80 (nginx) → Port 5000 (Pareng Boyong)
```

This setup allows you to:
- ✅ Access via `http://win-ai.innovatehub.site` (no port!)
- ✅ Avoid port conflicts (Pareng Boyong uses port 5000)
- ✅ Run Pareng Boyong without Administrator privileges
- ✅ Easily add more services in the future

## Why Nginx Reverse Proxy?

### Problem:
- Port 80 might conflict with other applications
- Running on port 80 requires Administrator privileges
- You wanted access without typing port number

### Solution:
- **Nginx** listens on port 80 (requires admin once at startup)
- **Pareng Boyong** runs on port 5000 (no admin, no conflicts)
- Nginx forwards requests from port 80 → localhost:5000
- Users access without port number

## Configuration

### Pareng Boyong (.env)
```env
WEB_UI_HOST=0.0.0.0
WEB_UI_PORT=5000
```

### Nginx (nginx.conf)
Located: `D:\Boyong\nginx-1.26.2\conf\nginx.conf`

Key configuration:
```nginx
server {
    listen       80;
    server_name  win-ai.innovatehub.site 130.105.71.58;

    location / {
        proxy_pass http://localhost:5000;
        # ... proxy headers ...
    }
}
```

## How to Start

### Method 1: All-in-One Script (Recommended)

**File:** `D:\Boyong\START_ALL_WITH_NGINX.bat`

**Steps:**
1. Right-click the file
2. Select **"Run as administrator"**
3. Wait for both services to start
4. Access: `http://win-ai.innovatehub.site`

This script:
- Starts nginx on port 80 (requires admin)
- Starts Pareng Boyong on port 5000 (no admin)
- Verifies both are running
- Shows access information

### Method 2: Start Separately

**Start Nginx:**
1. Right-click: `D:\Boyong\START_NGINX_ADMIN.bat`
2. Select "Run as administrator"

**Start Pareng Boyong:**
1. Open Command Prompt (no admin needed)
2. Run:
   ```batch
   cd D:\Boyong\agent-zero
   venv\Scripts\activate
   python run_ui.py
   ```

## Access URLs

### No Port Number Needed!

**Local:**
```
http://localhost
```

**Network:**
```
http://192.168.55.103
```

**Public:**
```
http://win-ai.innovatehub.site
http://130.105.71.58
```

**Login:**
- Username: `admin`
- Password: `innovatehub2026`

## How to Stop

### Stop Nginx:
```batch
D:\Boyong\STOP_NGINX.bat
```

### Stop Pareng Boyong:
- Close the "Pareng Boyong" command window
- OR: `taskkill /F /IM python.exe`

## Verification

### Check if Nginx is Running:
```batch
tasklist | findstr "nginx.exe"
```

Should show 2 processes (master and worker)

### Check if Pareng Boyong is Running:
```batch
netstat -ano | findstr ":5000" | findstr "LISTENING"
```

Should show port 5000 listening

### Test Port 80:
```batch
curl -I http://localhost
```

Should show response from Pareng Boyong (forwarded by nginx)

### Test External Access:
Open browser: `http://win-ai.innovatehub.site`

## Troubleshooting

### Issue: Nginx won't start (port 80 conflict)

**Find what's using port 80:**
```batch
netstat -ano | findstr ":80 " | findstr "LISTENING"
```

**Stop the conflicting service:**
```batch
taskkill /F /PID [process_id]
```

### Issue: "This script must be run as Administrator"

**Solution:**
- Don't double-click the script
- Right-click → "Run as administrator"

### Issue: Nginx starts but site doesn't work

**Check nginx logs:**
```
D:\Boyong\nginx-1.26.2\logs\error.log
D:\Boyong\nginx-1.26.2\logs\access.log
```

**Verify Pareng Boyong is on port 5000:**
```batch
netstat -ano | findstr ":5000"
```

**Test nginx configuration:**
```batch
cd D:\Boyong\nginx-1.26.2
nginx.exe -t
```

### Issue: Cannot access from internet

**Check DNS:**
```batch
nslookup win-ai.innovatehub.site
```
Should return: `130.105.71.58` (not 37.44.244.226)

**Check Windows Firewall:**
```powershell
# Run as Administrator
New-NetFirewallRule -DisplayName "HTTP Port 80" -Direction Inbound -LocalPort 80 -Protocol TCP -Action Allow
```

**Check router port forwarding:**
- External Port: 80
- Internal IP: 192.168.55.103
- Internal Port: 80

### Issue: "502 Bad Gateway"

This means nginx is working but can't reach Pareng Boyong.

**Check if Pareng Boyong is running:**
```batch
netstat -ano | findstr ":5000"
```

**Start Pareng Boyong if not running**

## Configuration Files

### Nginx Configuration
- **Location:** `D:\Boyong\nginx-1.26.2\conf\nginx.conf`
- **Backup:** `D:\Boyong\nginx-1.26.2\conf\nginx.conf.backup`

### Pareng Boyong Configuration
- **Location:** `D:\Boyong\agent-zero\.env`

### Scripts
- `START_ALL_WITH_NGINX.bat` - Start everything (use this!)
- `START_NGINX_ADMIN.bat` - Start only nginx
- `STOP_NGINX.bat` - Stop nginx
- `START_ALL.bat` - Old script (port 80 direct, no nginx)
- `RESTART_ALL.bat` - Restart script

## Adding More Services

With nginx, you can easily host multiple services:

```nginx
# In nginx.conf, add another server block:

server {
    listen       80;
    server_name  another-service.innovatehub.site;

    location / {
        proxy_pass http://localhost:8000;
        # ... same proxy headers ...
    }
}
```

## Network Architecture

```
┌──────────────────────────────────────────────┐
│            Internet / Users                  │
└────────────────┬─────────────────────────────┘
                 │
                 ▼
┌────────────────────────────────────────────────┐
│  DNS: win-ai.innovatehub.site → 130.105.71.58 │
└────────────────┬───────────────────────────────┘
                 │
                 ▼
┌────────────────────────────────────────────────┐
│  Router (Port 80 forwarding)                   │
│  External: 80 → Internal: 192.168.55.103:80    │
└────────────────┬───────────────────────────────┘
                 │
                 ▼
┌────────────────────────────────────────────────┐
│  Windows Server (192.168.55.103)               │
│  ┌──────────────────────────────────────────┐ │
│  │  Port 80: Nginx (Reverse Proxy)         │ │
│  │  - Requires Administrator                │ │
│  │  - Forwards to localhost:5000            │ │
│  └────────────┬─────────────────────────────┘ │
│               │                                 │
│               ▼                                 │
│  ┌──────────────────────────────────────────┐ │
│  │  Port 5000: Pareng Boyong                │ │
│  │  - No Administrator needed               │ │
│  │  - Flask Application                     │ │
│  │  - Agent Zero Framework                  │ │
│  └──────────────────────────────────────────┘ │
└────────────────────────────────────────────────┘
```

## Security Notes

### Port 80 Open to Internet
- Nginx is now handling port 80
- Ensure strong authentication in Pareng Boyong
- Monitor nginx access logs

### Nginx Security
- Nginx is widely used and secure
- Regularly check for updates
- Current version: 1.26.2

### Pareng Boyong Security
- Not directly exposed (behind nginx)
- Only accessible via localhost:5000 or through nginx
- Authentication enabled (admin/innovatehub2026)

## Performance Benefits

1. **Nginx is Fast**
   - Efficiently handles static files
   - Optimized for concurrent connections
   - Low memory footprint

2. **Better for Production**
   - Proper HTTP headers
   - Connection pooling
   - Request buffering

3. **Scalability**
   - Can add load balancing later
   - Can add caching
   - Can add rate limiting

## Nginx Commands

### Start:
```batch
cd D:\Boyong\nginx-1.26.2
nginx.exe
```

### Stop (graceful):
```batch
nginx.exe -s quit
```

### Stop (immediate):
```batch
nginx.exe -s stop
```

### Reload config (no downtime):
```batch
nginx.exe -s reload
```

### Test configuration:
```batch
nginx.exe -t
```

## Summary

### What You Get:
- ✅ Access without port number: `http://win-ai.innovatehub.site`
- ✅ No port conflicts (Pareng Boyong on 5000)
- ✅ Professional reverse proxy setup
- ✅ Easy to add more services
- ✅ Better security and performance

### What You Need to Do:
1. Update DNS to `130.105.71.58` (if not done)
2. Right-click `START_ALL_WITH_NGINX.bat` → "Run as administrator"
3. Wait 20 seconds for startup
4. Access: `http://win-ai.innovatehub.site`
5. Login: admin / innovatehub2026

### Requirements:
- Administrator privileges (for nginx on port 80 only, once at startup)
- DNS pointing to Windows server (130.105.71.58)
- Windows Firewall allowing port 80
- Router forwarding port 80 to 192.168.55.103

---

**Everything is configured and ready!** 🚀

Just start the services and update your DNS.

---
*Last updated: 2026-01-13*
*Nginx version: 1.26.2*
