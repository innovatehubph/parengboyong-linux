<div align="center">

# Pareng Boyong - Linux VPS Edition

**Production-Ready Linux Deployment**

[![Live Demo](https://img.shields.io/badge/Live-ai.innovatehub.site-success?style=for-the-badge)](https://ai.innovatehub.site)
[![Docker](https://img.shields.io/badge/Docker-enabled-blue?style=for-the-badge&logo=docker)](https://www.docker.com/)
[![InnovateHub](https://img.shields.io/badge/Website-innovatehub.ph-0A192F?style=for-the-badge)](https://innovatehub.ph)

---

### 🎯 Production Linux VPS Deployment

This repository contains the **exact production configuration** running on our Linux VPS at **ai.innovatehub.site**.

✅ Fully configured ✅ Tested & working ✅ Ready to deploy

</div>

---

## 📦 What's Inside

This is **NOT** a clone of the generic Agent Zero framework. This is our **production-tested Linux VPS configuration** with:

- 🤖 **Pareng Boyong** - Filipino AI assistant (not "Agent Zero")
- 👤 **Boss Marc** - Personalized user experience
- 🇵🇭 **Filipino Agent Names** - Juan, Pedro, Jose, Maria, etc.
- 🐳 **Docker Deployment** - Containerized for reliability
- 🔒 **Nginx + SSL** - Production web server with HTTPS
- ⚙️ **Complete Configuration** - All production settings included

---

## 🚀 Quick Deploy

### Prerequisites

- Ubuntu 22.04+ or Debian 11+ VPS
- Docker installed
- Domain name configured
- Root access

### Deploy in 5 Commands

```bash
# 1. Clone this repo
git clone https://github.com/innovatehubph/parengboyong-linux.git
cd parengboyong-linux

# 2. Create data directory
mkdir -p /root/pareng-boyong-data

# 3. Pull Docker image
docker pull agent0ai/agent-zero:latest

# 4. Copy production code to data directory
cp agent.py prompts/fw.initial_message.md python/api/message.py python/api/api_message.py python/helpers/task_scheduler.py /root/pareng-boyong-data/

# 5. Run container
docker run -d \
  --name pareng-boyong \
  --restart unless-stopped \
  -p 50002:80 \
  -v /root/pareng-boyong-data:/a0 \
  agent0ai/agent-zero:latest
```

**See Full Guide:** [LINUX_DEPLOYMENT.md](LINUX_DEPLOYMENT.md)

---

## 💡 Key Features

### Production Customizations

| Feature | Description |
|---------|-------------|
| **Main Agent** | "Pareng Boyong" instead of "A0" |
| **User Label** | "Boss Marc" instead of "User Message" |
| **Subordinates** | Filipino names (Juan, Pedro, Jose, Maria...) |
| **Welcome Message** | Customized greeting |
| **Deployment** | Docker + Nginx + SSL/TLS |

### Technical Stack

- **Platform:** Ubuntu 22.04 LTS
- **Container:** Docker (agent-zero:latest)
- **Web Server:** Nginx 1.28
- **SSL:** Let's Encrypt (auto-renewal)
- **Port:** 50002 (internal)
- **Storage:** Persistent volume mounted

---

## 🏗️ Architecture

```
Internet Users
      ↓
HTTPS (443) - SSL Certificate
      ↓
Nginx Reverse Proxy
      ↓
localhost:50002
      ↓
Docker Container
      ↓
Pareng Boyong App
      ↓
/root/pareng-boyong-data/ (persistent storage)
```

---

## ⚙️ Production Configuration

### Files Modified for Production

1. **agent.py** - Filipino agent names system
2. **prompts/fw.initial_message.md** - Custom welcome message
3. **python/api/message.py** - User label "Boss Marc"
4. **python/api/api_message.py** - API user label
5. **python/helpers/task_scheduler.py** - Scheduler label

### Environment Variables

Located at: `/root/pareng-boyong-data/.env`

```env
# Authentication
BASIC_AUTH_USERNAME=admin
BASIC_AUTH_PASSWORD=innovatehub2026

# CORS
ALLOWED_ORIGINS=https://ai.innovatehub.site

# Runtime (auto-generated)
A0_PERSISTENT_RUNTIME_ID=auto-generated-id
```

---

## 🔧 Management

### Container Commands

```bash
# View real-time logs
docker logs -f pareng-boyong

# Restart
docker restart pareng-boyong

# Check status
docker ps | grep pareng-boyong

# Monitor resources
docker stats pareng-boyong
```

### Nginx Commands

```bash
# Restart Nginx
systemctl restart nginx

# Check status
systemctl status nginx

# Test configuration
nginx -t
```

### SSL Certificate

```bash
# Check certificate
certbot certificates

# Renew (auto-renews via cron)
certbot renew
```

---

## 📚 Documentation

| Document | Purpose |
|----------|---------|
| [LINUX_DEPLOYMENT.md](LINUX_DEPLOYMENT.md) | Complete setup guide (583 lines) |
| [DEPLOYMENT_SUMMARY.md](DEPLOYMENT_SUMMARY.md) | Architecture overview (467 lines) |
| [CHAT_REBRANDING_SUMMARY.md](CHAT_REBRANDING_SUMMARY.md) | UI customization details (345 lines) |
| [WINDOWS_DEPLOYMENT.md](WINDOWS_DEPLOYMENT.md) | Windows Server deployment |
| [VPS_SETUP_COMPLETE.md](VPS_SETUP_COMPLETE.md) | Post-installation reference |
| [INSTALLATION_SUMMARY.md](INSTALLATION_SUMMARY.md) | Installation history |

---

## 🔒 Security Features

- ✅ **SSL/TLS Encryption** - Let's Encrypt certificates
- ✅ **Password Authentication** - Basic auth enabled
- ✅ **CORS Protection** - Domain whitelist
- ✅ **Firewall** - Only ports 22, 80, 443 open
- ✅ **Container Isolation** - Docker security
- ✅ **Auto SSL Renewal** - Automated via systemd

---

## 🚨 Troubleshooting

### Container Issues

```bash
# Check logs
docker logs pareng-boyong

# Restart
docker restart pareng-boyong

# Recreate if needed
docker stop pareng-boyong && docker rm pareng-boyong
docker run -d --name pareng-boyong --restart unless-stopped \
  -p 50002:80 -v /root/pareng-boyong-data:/a0 \
  agent0ai/agent-zero:latest
```

### Website Not Accessible

```bash
# Check DNS
nslookup ai.innovatehub.site

# Check Nginx
systemctl status nginx
nginx -t

# Check container
docker ps | grep pareng-boyong
```

---

## 💾 Backup & Restore

### Backup

```bash
# Backup data
tar -czf ~/pareng-boyong-backup-$(date +%Y%m%d).tar.gz \
  /root/pareng-boyong-data/

# Backup Nginx config
cp /etc/nginx/sites-available/ai.innovatehub.site \
  ~/nginx-backup.conf
```

### Restore

```bash
docker stop pareng-boyong
tar -xzf ~/pareng-boyong-backup-YYYYMMDD.tar.gz -C /
docker start pareng-boyong
```

---

## 📊 Production Status

**Live URL:** https://ai.innovatehub.site
**Platform:** Ubuntu 22.04 LTS
**Container:** agent0ai/agent-zero:latest
**SSL:** Valid ✅
**Status:** Production Ready ✅

**First Deployed:** 2026-01-12
**Last Updated:** 2026-01-13

---

## 🤝 Related Repositories

- **Main Repository:** [pareng-boyong](https://github.com/innovatehubph/pareng-boyong) - Multi-platform
- **Windows Edition:** Coming soon

---

## 🙏 Credits

- **InnovateHub Team** - Production deployment
- **Claude Sonnet 4.5** - AI-assisted configuration
- **Docker** - Containerization
- **Nginx** - Web server
- **Let's Encrypt** - SSL certificates

---

## 📝 License

MIT License - see [LICENSE](LICENSE) file

---

**© 2026 InnovateHub. All rights reserved.**

