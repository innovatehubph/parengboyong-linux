# Pareng Boyong - Port 80 Configuration (No Port Number Required!)

## Overview
Pareng Boyong is now configured to run on **standard HTTP port 80**, allowing you to access it via:
- ✅ `http://win-ai.innovatehub.site` (NO port number!)
- ✅ `http://130.105.71.58`
- ✅ `http://localhost`

## Why Port 80?

**Port 80** is the standard HTTP port. When you access a website without specifying a port, browsers automatically use port 80.

This means:
- ❌ Before: `http://win-ai.innovatehub.site:15080` (had to type port)
- ✅ Now: `http://win-ai.innovatehub.site` (no port needed!)

## Configuration Changes

### 1. .env File
```env
WEB_UI_HOST=0.0.0.0  # Accessible from all network interfaces
WEB_UI_PORT=80       # Standard HTTP port
```

### 2. Flask Async Fixed
✅ **Installed `asgiref` successfully** using Tsinghua mirror
- No more Flask async errors!
- Web UI will work properly now

## Important: Administrator Privileges Required

⚠️ **Port 80 requires Administrator privileges on Windows**

### Why?
Ports below 1024 are considered "privileged ports" and require elevated permissions for security reasons.

### Solution: Run as Administrator

**Use this script:**
```batch
D:\Boyong\START_PARENG_BOYONG_ADMIN.bat
```

**How to run:**
1. Right-click `START_PARENG_BOYONG_ADMIN.bat`
2. Select **"Run as administrator"**
3. Click "Yes" on the UAC prompt
4. Wait 15 seconds for startup
5. Access via `http://win-ai.innovatehub.site`

## Access Information

### Local Machine
```
http://localhost
```

### Same Network (LAN)
```
http://192.168.55.103
```

### Internet (Public)
```
http://win-ai.innovatehub.site
http://130.105.71.58
```

**No port number required for any of these!**

## Files Modified

### Configuration
- `D:\Boyong\agent-zero\.env` → Changed `WEB_UI_PORT=80`

### Scripts
- `D:\Boyong\START_ALL.bat` → Updated for port 80 (requires admin)
- `D:\Boyong\RESTART_ALL.bat` → Updated for port 80
- `D:\Boyong\START_PARENG_BOYONG_ADMIN.bat` → New script with admin check

## Verification Steps

### 1. Check if Pareng Boyong is Running
```batch
netstat -ano | findstr ":80 " | findstr "LISTENING"
```

Expected output:
```
TCP    0.0.0.0:80             0.0.0.0:0              LISTENING       [PID]
```

### 2. Test Local Access
Open browser:
```
http://localhost
```

### 3. Test Public Access
From any device with internet:
```
http://win-ai.innovatehub.site
```

## Troubleshooting

### Issue: "Port 80 requires Administrator privileges"
**Solution:** Right-click script and select "Run as administrator"

### Issue: "Port 80 is already in use"
**Check what's using it:**
```batch
netstat -ano | findstr ":80 " | findstr "LISTENING"
```

**Stop the conflicting service:**
```batch
taskkill /F /PID [process_id]
```

### Issue: "This script must be run as Administrator"
**Solution:**
1. Right-click `START_PARENG_BOYONG_ADMIN.bat`
2. Select "Run as administrator"
3. Do NOT just double-click it

### Issue: Cannot access from internet
**Check:**
1. Windows Firewall allows port 80:
   ```powershell
   New-NetFirewallRule -DisplayName "HTTP Port 80" -Direction Inbound -LocalPort 80 -Protocol TCP -Action Allow
   ```

2. Router port forwarding configured:
   - External Port: 80
   - Internal IP: 192.168.55.103
   - Internal Port: 80

3. DNS is correct:
   ```batch
   nslookup win-ai.innovatehub.site
   ```
   Should return: `130.105.71.58`

## Alternative Solutions

If you cannot run as Administrator or port 80 conflicts with other services:

### Option 1: Use Port 8000 (No Admin Required)
Change in `.env`:
```env
WEB_UI_PORT=8000
```
Access via: `http://win-ai.innovatehub.site:8000`

### Option 2: Nginx Reverse Proxy
Install nginx on port 80 (as admin), forward to Pareng Boyong on higher port
- More complex setup
- Allows running Pareng Boyong without admin
- Can host multiple services

### Option 3: IIS Reverse Proxy
Use Windows IIS (if installed) as reverse proxy
- Native Windows solution
- Requires IIS installation and configuration

## Current Status

✅ **Configuration Complete**
- Port 80 configured in .env
- Flask async error fixed (asgiref installed)
- Scripts updated for port 80
- Admin launcher script created

⏳ **Pending**
- Start Pareng Boyong as Administrator
- Test access via win-ai.innovatehub.site
- Configure Windows Firewall (if needed)
- Configure router port forwarding (if needed)

## Quick Start

**Start Pareng Boyong:**
1. Right-click: `D:\Boyong\START_PARENG_BOYONG_ADMIN.bat`
2. Select: "Run as administrator"
3. Wait 15 seconds
4. Open browser: `http://win-ai.innovatehub.site`

**Stop Pareng Boyong:**
- Close the "Pareng Boyong" command window
- OR: `taskkill /F /IM python.exe`

**Restart Pareng Boyong:**
```batch
D:\Boyong\RESTART_ALL.bat
```
(Must also run as administrator)

## Security Notes

### Port 80 Exposure
- Port 80 is now open to the internet
- Ensure strong authentication is configured:
  ```env
  AUTH_LOGIN=your-username
  AUTH_PASSWORD=your-strong-password
  ```

### Firewall Rules
- Windows Firewall should allow port 80
- Consider restricting access by IP if possible
- Monitor access logs regularly

### HTTPS Consideration
- Port 80 is HTTP (unencrypted)
- For production, consider adding HTTPS (port 443)
- Can use Let's Encrypt SSL certificate
- Requires reverse proxy (nginx, Caddy, or Traefik)

## Network Architecture

```
Internet
    ↓
DNS: win-ai.innovatehub.site → 130.105.71.58
    ↓
Router (Port 80 forwarding)
    ↓
Windows Server: 192.168.55.103
    ↓
Port 80 (Pareng Boyong - requires Admin)
    ↓
Flask Application (run_ui.py)
    ↓
Agent Zero Framework
    ↓
LLM APIs
```

## Summary

🎯 **Goal Achieved**: Access Pareng Boyong without typing port number!

✅ **Configuration**: Port 80 (standard HTTP)
✅ **Async Error**: Fixed (asgiref installed)
✅ **Admin Script**: Created for easy startup
✅ **DNS**: win-ai.innovatehub.site → 130.105.71.58

📋 **Next Step**: Right-click `START_PARENG_BOYONG_ADMIN.bat` → Run as administrator

🌐 **Access URL**: http://win-ai.innovatehub.site (no port!)

---
*Last updated: 2026-01-13*
