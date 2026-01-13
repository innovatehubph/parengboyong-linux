# Pareng Boyong - Innovatehub AI

AI-powered assistant framework based on Agent Zero, customized for Innovatehub.

## Quick Start

### Access via Web (No Port Number!)
```
http://win-ai.innovatehub.site
```

**Login:**
- Username: `admin`
- Password: `innovatehub2026`

### Start Everything (One Command)

**Right-click and Run as Administrator:**
```batch
D:\Boyong\START_ALL_WITH_NGINX.bat
```

This starts:
1. Nginx reverse proxy on port 80
2. Pareng Boyong on port 5000

## Architecture

```
Internet → Port 80 (nginx) → Port 5000 (Pareng Boyong/Flask)
```

**Benefits:**
- ✅ Access without port number
- ✅ No port conflicts
- ✅ Professional reverse proxy
- ✅ Easy to scale

## Requirements

- Windows Server (Administrator access for nginx)
- Python 3.12+ with virtual environment
- Nginx 1.26.2 (included)
- AI Provider API Keys (Anthropic, OpenAI, etc.)

## Directory Structure

```
D:\Boyong\
├── agent-zero/              # Main application
│   ├── venv/               # Python virtual environment
│   ├── .env                # Configuration (API keys, ports)
│   ├── run_ui.py           # Flask web server
│   └── prompts/            # AI agent prompts
├── nginx-1.26.2/           # Nginx reverse proxy
│   └── conf/nginx.conf     # Nginx configuration
├── START_ALL_WITH_NGINX.bat    # Main startup script
├── STOP_NGINX.bat              # Stop nginx
└── README.md                   # This file
```

## Configuration

### DNS Configuration
```
Domain: win-ai.innovatehub.site
Type: A
Points to: 130.105.71.58
```

### Application Ports
- **Port 80**: Nginx (external access)
- **Port 5000**: Pareng Boyong (internal)

### Environment Variables
File: `D:\Boyong\agent-zero\.env`

```env
# Web UI
WEB_UI_HOST=0.0.0.0
WEB_UI_PORT=5000

# Authentication
AUTH_LOGIN=admin
AUTH_PASSWORD=innovatehub2026

# AI Provider Keys
API_KEY_ANTHROPIC=your-key
API_KEY_OPENAI=your-key
# ... etc
```

## Management Scripts

### Start Everything
```batch
START_ALL_WITH_NGINX.bat  (Run as Administrator)
```

### Stop Services
```batch
STOP_NGINX.bat           # Stop nginx
taskkill /F /IM python.exe    # Stop Pareng Boyong
```

### Restart After Updates
```batch
UPDATE_AND_RESTART.bat   (Run as Administrator)
```

## Documentation

- **NGINX_REVERSE_PROXY_SETUP.md** - Complete nginx setup guide
- **AGENT_ZERO_FRAMEWORK.md** - Agent Zero technical reference
- **DNS_SETUP_GUIDE.md** - DNS configuration instructions
- **FLASK_ASYNC_FIX.md** - Troubleshooting Flask async issues

## Troubleshooting

### Can't access from internet
1. Check DNS: `nslookup win-ai.innovatehub.site` (should be 130.105.71.58)
2. Check firewall: Port 80 must be allowed
3. Check router: Port 80 forwarded to 192.168.55.103
4. Check nginx: `tasklist | findstr nginx.exe`

### "This script must be run as Administrator"
- Don't double-click the script
- Right-click → "Run as administrator"

### 502 Bad Gateway
- Pareng Boyong isn't running on port 5000
- Start it: `cd agent-zero && venv\Scripts\activate && python run_ui.py`

### Check nginx logs
```
D:\Boyong\nginx-1.26.2\logs\error.log
D:\Boyong\nginx-1.26.2\logs\access.log
```

## Security

- Port 80 open to internet (protected by nginx)
- Authentication required (admin/innovatehub2026)
- Change default password in `.env`
- Monitor nginx access logs
- Consider adding HTTPS (future enhancement)

## Tech Stack

- **Frontend**: React-based Web UI
- **Backend**: Python/Flask (Agent Zero framework)
- **Reverse Proxy**: Nginx 1.26.2
- **AI Models**: Multiple providers via LiteLLM
  - Anthropic (Claude)
  - OpenAI (GPT)
  - Google (Gemini)
  - Groq, Mistral, etc.

## Network Architecture

```
┌─────────────────────────────────────┐
│  Internet / Users                   │
└────────────┬────────────────────────┘
             │
             ▼
┌─────────────────────────────────────┐
│  DNS: win-ai.innovatehub.site       │
│  → 130.105.71.58                    │
└────────────┬────────────────────────┘
             │
             ▼
┌─────────────────────────────────────┐
│  Windows Server (192.168.55.103)    │
│  ┌─────────────────────────────┐   │
│  │  Port 80: Nginx             │   │
│  │  (Reverse Proxy)            │   │
│  └───────────┬─────────────────┘   │
│              │                      │
│              ▼                      │
│  ┌─────────────────────────────┐   │
│  │  Port 5000: Pareng Boyong   │   │
│  │  (Flask/Agent Zero)         │   │
│  └─────────────────────────────┘   │
└─────────────────────────────────────┘
```

## Features

### Agent Zero Capabilities
- Multi-agent cooperation
- Persistent memory
- Code execution
- Web search
- File operations
- Custom tools/instruments
- RAG (Retrieval-Augmented Generation)
- Voice interfaces (TTS/STT)
- Browser automation

### Pareng Boyong Customizations
- Rebranded UI (Innovatehub theme)
- Custom logo and branding
- Port 5000 with nginx reverse proxy
- Windows Server optimized
- D: drive full access

## Development

### Adding AI Provider Keys
Edit `D:\Boyong\agent-zero\.env`:
```env
API_KEY_ANTHROPIC=sk-ant-xxxxx
API_KEY_OPENAI=sk-xxxxx
API_KEY_GOOGLE=xxxxx
```

### Customizing Agent Behavior
Edit system prompt:
```
D:\Boyong\agent-zero\prompts\default\agent.system.md
```

### Adding Custom Tools
Add to:
```
D:\Boyong\agent-zero\python\tools\
```

## Links

- **GitHub**: https://github.com/innovatehubph/pareng-boyong
- **Website**: https://innovatehub.ph
- **Agent Zero**: https://github.com/agent0ai/agent-zero
- **Access**: http://win-ai.innovatehub.site

## Support

For issues or questions:
1. Check documentation in `D:\Boyong\`
2. Review nginx logs
3. Check GitHub repository issues
4. Contact Innovatehub support

---

## Quick Reference

**Start:** Right-click `START_ALL_WITH_NGINX.bat` → Run as administrator
**Stop:** `STOP_NGINX.bat` + close Pareng Boyong window
**Access:** http://win-ai.innovatehub.site
**Login:** admin / innovatehub2026

---

*Powered by Agent Zero Framework*
*Customized for Innovatehub*
*Last updated: 2026-01-13*
