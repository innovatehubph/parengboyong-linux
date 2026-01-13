# Pareng Boyong - Port 15080 Configuration

## Overview
Pareng Boyong has been configured to run on **port 15080** to avoid conflicts with other applications running on this Windows server.

## Why Port 15080?
- **Uncommon port**: Won't conflict with standard applications
- **Out of common ranges**: Avoids ports used by:
  - Port 80/443 (HTTP/HTTPS - used by lighttpd serving skyworth site)
  - Port 8080 (XAMPP or other web server)
  - Port 5000 (Flask default - used by other apps)
  - Port 3000-9000 (Common development ports)
- **Safe and memorable**: Easy to remember, won't interfere with future applications

## Access URLs

### Local Access
```
http://localhost:15080
```

### Network Access (from other devices on your LAN)
```
http://192.168.55.103:15080
```

### Public Access (from anywhere on the internet)
```
http://win-ai.innovatehub.site:15080
http://130.105.71.58:15080
```

## Configuration Files Modified

### 1. D:\Boyong\agent-zero\.env
Added:
```env
# Web UI Configuration
# Host: 0.0.0.0 makes it accessible from all network interfaces
# Port: 15080 is an uncommon port that won't conflict with standard applications
WEB_UI_HOST=0.0.0.0
WEB_UI_PORT=15080
```

### 2. D:\Boyong\START_ALL.bat
Updated to:
- Check port 15080 instead of 5000
- Display correct access URLs
- Removed Docker/Traefik complexity (not needed)

### 3. D:\Boyong\RESTART_ALL.bat
Updated to:
- Simplified to only restart Pareng Boyong
- Removed unnecessary Docker/Traefik steps

## Starting Pareng Boyong

### Method 1: Using START_ALL.bat (Recommended)
```batch
D:\Boyong\START_ALL.bat
```
This script will:
1. Check if Pareng Boyong is running
2. Start it if not running
3. Verify DNS configuration
4. Display access information

### Method 2: Manual Start
```batch
cd D:\Boyong\agent-zero
venv\Scripts\activate
python run_ui.py
```

## Restarting Pareng Boyong

```batch
D:\Boyong\RESTART_ALL.bat
```

## Updating from GitHub

```batch
D:\Boyong\UPDATE_AND_RESTART.bat
```

## Firewall Configuration

Ensure Windows Firewall allows inbound connections on port 15080:

```powershell
# Run as Administrator
New-NetFirewallRule -DisplayName "Pareng Boyong (Port 15080)" -Direction Inbound -LocalPort 15080 -Protocol TCP -Action Allow
```

## Router Port Forwarding

If you want external access, configure your router to forward:
- External Port: 15080
- Internal IP: 192.168.55.103
- Internal Port: 15080
- Protocol: TCP

## Current Issues

### Flask Async Error
The application currently has a Flask async dependency issue:
```
RuntimeError: Install Flask with the 'async' extra in order to use async views.
```

**Resolution**: Install asgiref package when network connectivity is stable:
```bash
cd D:\Boyong\agent-zero
venv\Scripts\pip.exe install asgiref
```

## Network Architecture

```
Internet
    ↓
DNS: win-ai.innovatehub.site → 130.105.71.58
    ↓
Windows Server (130.105.71.58)
    ↓
Port 15080
    ↓
Pareng Boyong (Flask Application)
    ↓
Agent Zero AI Framework
```

## Troubleshooting

### Port Already in Use
Check what's using port 15080:
```batch
netstat -ano | findstr ":15080"
```

### Cannot Access Externally
1. Check Windows Firewall (see above)
2. Check router port forwarding
3. Verify DNS: `nslookup win-ai.innovatehub.site`
4. Test locally first: `http://localhost:15080`

### Pareng Boyong Won't Start
1. Check if another instance is running
2. Review error logs in the console window
3. Verify .env configuration
4. Check Python environment: `D:\Boyong\agent-zero\venv\Scripts\python.exe --version`

## Alternative Ports

If port 15080 conflicts with future applications, consider these alternatives:
- **18080** - Also safe and uncommon
- **20080** - Very uncommon, very safe
- **25080** - Rarely used

To change the port, edit `D:\Boyong\agent-zero\.env`:
```env
WEB_UI_PORT=18080  # Change to desired port
```

## Security Notes

- Port 15080 is now open to the internet
- Ensure strong authentication is configured in .env:
  ```env
  AUTH_LOGIN=your-username
  AUTH_PASSWORD=your-strong-password
  ```
- Consider using HTTPS for production (requires reverse proxy or certificate)
- Monitor access logs regularly

## Summary

✅ **Configured**: Port 15080 for Pareng Boyong
✅ **Updated**: START_ALL.bat and RESTART_ALL.bat scripts
✅ **Simplified**: No Docker/Traefik complexity
✅ **Accessible**: Via win-ai.innovatehub.site:15080
⏳ **Pending**: Flask async package installation (network timeout)

---
*Last updated: 2026-01-13*
