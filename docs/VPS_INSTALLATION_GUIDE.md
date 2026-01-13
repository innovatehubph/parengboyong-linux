# Pareng Boyong VPS Installation Guide

## Complete Step-by-Step Installation on Linux VPS

This guide documents the complete installation process for deploying Pareng Boyong (InnovateHub AI's Agent Zero) on a Linux VPS with Docker, Nginx reverse proxy, and automatic HTTPS.

---

## Table of Contents

1. [Prerequisites](#prerequisites)
2. [Step 1: Clone Repository](#step-1-clone-repository)
3. [Step 2: Install Docker](#step-2-install-docker)
4. [Step 3: Pull Docker Image](#step-3-pull-docker-image)
5. [Step 4: Create Data Directory](#step-4-create-data-directory)
6. [Step 5: Run Docker Container](#step-5-run-docker-container)
7. [Step 6: Verify Installation](#step-6-verify-installation)
8. [Step 7: Apply Rebranding](#step-7-apply-rebranding)
9. [Step 8: Configure Domain (Optional)](#step-8-configure-domain-optional)
10. [Step 9: Install Nginx](#step-9-install-nginx)
11. [Step 10: Configure Reverse Proxy](#step-10-configure-reverse-proxy)
12. [Step 11: Setup SSL Certificate](#step-11-setup-ssl-certificate)
13. [Step 12: Final Testing](#step-12-final-testing)
14. [Troubleshooting](#troubleshooting)

---

## Prerequisites

Before starting, ensure you have:

- **Linux VPS** with root access (Ubuntu 20.04+ or similar)
- **Minimum 2GB RAM** (4GB recommended)
- **Minimum 20GB disk space**
- **Domain name** (optional, for HTTPS setup)
- **DNS configured** (if using domain)
- **Internet connection**

### System Requirements

```bash
# Check system
uname -a
# Should show: Linux with kernel 4.x or higher

# Check available resources
free -h  # Memory
df -h    # Disk space
```

---

## Step 1: Clone Repository

### 1.1 Navigate to Working Directory

```bash
cd /root
```

### 1.2 Clone the Repository

```bash
git clone https://github.com/innovatehubph/pareng-boyong.git
```

**Expected Output:**
```
Cloning into 'pareng-boyong'...
remote: Enumerating objects: ...
remote: Total ... (delta ...), reused ... (delta ...)
Receiving objects: 100% (...), done.
Resolving deltas: 100% (...), done.
```

### 1.3 Verify Clone

```bash
cd pareng-boyong
ls -la
```

**Expected Output:**
```
drwxr-xr-x 21 root root  4096 Jan 12 18:21 .
drwx------ 10 root root  4096 Jan 12 18:20 ..
-rw-r--r--  1 root root  1431 Jan 12 18:21 .dockerignore
drwxr-xr-x  7 root root  4096 Jan 12 18:21 .git
-rw-r--r--  1 root root 15173 Jan 12 18:21 README.md
-rw-r--r--  1 root root 35785 Jan 12 18:21 agent.py
drwxr-xr-x  8 root root  4096 Jan 12 18:21 agents
drwxr-xr-x  7 root root  4096 Jan 12 18:21 webui
...
```

---

## Step 2: Install Docker

### 2.1 Check if Docker is Already Installed

```bash
docker --version
```

If Docker is installed, you'll see:
```
Docker version XX.X.X, build XXXXXXX
```

If not installed, continue with installation.

### 2.2 Install Docker (Ubuntu/Debian)

```bash
# Update package index
apt update

# Install dependencies
apt install -y apt-transport-https ca-certificates curl software-properties-common

# Add Docker's official GPG key
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg

# Set up stable repository
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null

# Install Docker Engine
apt update
apt install -y docker-ce docker-ce-cli containerd.io

# Start and enable Docker
systemctl start docker
systemctl enable docker
```

### 2.3 Verify Docker Installation

```bash
docker --version
docker ps
```

**Expected Output:**
```
Docker version 29.1.3, build f52814d
CONTAINER ID   IMAGE     COMMAND   CREATED   STATUS    PORTS     NAMES
```

---

## Step 3: Pull Docker Image

### 3.1 Pull the Agent Zero Image

```bash
docker pull agent0ai/agent-zero:latest
```

**Expected Output:**
```
latest: Pulling from agent0ai/agent-zero
Digest: sha256:ef3993faf67928d8bea4e1979c7cff417fcfb1d456b62af2831e43e7a47ebfb4
Status: Downloaded newer image for agent0ai/agent-zero:latest
docker.io/agent0ai/agent-zero:latest
```

This may take 5-10 minutes depending on your internet speed.

### 3.2 Verify Image Downloaded

```bash
docker images | grep agent-zero
```

**Expected Output:**
```
agent0ai/agent-zero   latest    abc123def456   2 days ago   2.5GB
```

---

## Step 4: Create Data Directory

### 4.1 Create Persistent Data Directory

```bash
mkdir -p /root/pareng-boyong-data
```

This directory will store:
- Configuration files (.env)
- Memory and knowledge base
- Logs
- Custom prompts
- User data

### 4.2 Verify Directory Created

```bash
ls -la /root/ | grep pareng-boyong
```

**Expected Output:**
```
drwxr-xr-x 21 root root  4096 Jan 12 18:21 pareng-boyong
drwxr-xr-x  2 root root  4096 Jan 12 18:30 pareng-boyong-data
```

---

## Step 5: Run Docker Container

### 5.1 Check Available Ports

```bash
# Check if port 50002 is available
netstat -tulpn | grep 50002
```

If the port is free, no output will be shown. If it's in use, choose a different port.

### 5.2 Run the Container

```bash
docker run -d \
  --name pareng-boyong \
  -p 50002:80 \
  -v /root/pareng-boyong-data:/a0 \
  agent0ai/agent-zero:latest
```

**Command Explanation:**
- `-d`: Run in detached mode (background)
- `--name pareng-boyong`: Container name
- `-p 50002:80`: Map host port 50002 to container port 80
- `-v /root/pareng-boyong-data:/a0`: Mount data directory
- `agent0ai/agent-zero:latest`: Image to use

**Expected Output:**
```
35ff8efa9b6d442ea6c2df66a7a06dd03981897cbbbca4fb81b2b6d98bb454d1
```

### 5.3 Verify Container is Running

```bash
docker ps | grep pareng-boyong
```

**Expected Output:**
```
35ff8efa9b6d   agent0ai/agent-zero:latest   "/exe/initialize.sh …"   1 minute ago   Up 1 minute   22/tcp, 9000-9009/tcp, 0.0.0.0:50002->80/tcp   pareng-boyong
```

### 5.4 Check Container Logs

```bash
docker logs pareng-boyong --tail 30
```

**Expected Output:**
```
Starting tunnel API...
Copying files from /git/agent-zero to /a0...
READY
Initializing framework...
Starting server...
 * Running on all addresses (0.0.0.0)
 * Running on http://127.0.0.1:80
```

Wait 30-60 seconds for the container to fully initialize.

---

## Step 6: Verify Installation

### 6.1 Test Local Access

```bash
curl -s http://localhost:50002 | grep -o "<title>.*</title>"
```

**Expected Output:**
```
<title>Agent Zero</title>
```

### 6.2 Get Server IP Address

```bash
hostname -I | awk '{print $1}'
```

**Example Output:**
```
37.44.244.226
```

### 6.3 Test Remote Access

From your local computer, visit:
```
http://YOUR_SERVER_IP:50002
```

You should see the Agent Zero web interface.

---

## Step 7: Apply Rebranding

### 7.1 Wait for Files to Copy

The container needs to copy files to the data directory. Wait 1-2 minutes, then check:

```bash
ls -la /root/pareng-boyong-data/
```

**Expected Output:**
```
drwxr-xr-x 21 root root  4096 Jan 12 18:33 .
-rw-r--r--  1 root root   107 Jan 12 18:34 .env
-rw-r--r--  1 root root 35785 Jan 12 18:33 agent.py
drwxr-xr-x  8 root root  4096 Jan 12 18:33 agents
drwxr-xr-x  7 root root  4096 Jan 12 18:33 webui
...
```

### 7.2 Backup Original Index File

```bash
cp /root/pareng-boyong-data/webui/index.html /root/pareng-boyong-data/webui/index.html.backup
```

### 7.3 Update Page Title

```bash
sed -i 's/<title>Agent Zero<\/title>/<title>Innovatehub AI '\''Pareng Boyong'\''<\/title>/g' /root/pareng-boyong-data/webui/index.html
```

### 7.4 Verify Change

```bash
grep "<title>" /root/pareng-boyong-data/webui/index.html
```

**Expected Output:**
```
    <title>Innovatehub AI 'Pareng Boyong'</title>
```

### 7.5 Restart Container to Apply Changes

```bash
docker restart pareng-boyong
```

### 7.6 Wait for Restart

```bash
sleep 15
```

### 7.7 Verify Rebranding

```bash
curl -s http://localhost:50002 | grep -o "<title>.*</title>"
```

**Expected Output:**
```
<title>Innovatehub AI 'Pareng Boyong'</title>
```

---

## Step 8: Configure Domain (Optional)

Skip this section if you're using only IP address access.

### 8.1 Configure DNS

In your DNS provider (e.g., Hostinger):

1. Log in to your DNS management panel
2. Add an **A Record**:
   - **Type:** A
   - **Name:** ai (or your subdomain)
   - **Value:** Your VPS IP address (e.g., 37.44.244.226)
   - **TTL:** 300 (or default)

### 8.2 Verify DNS Propagation

```bash
nslookup ai.innovatehub.site
```

**Expected Output:**
```
Server:		127.0.0.53
Address:	127.0.0.53#53

Non-authoritative answer:
Name:	ai.innovatehub.site
Address: 37.44.244.226
```

If DNS hasn't propagated yet, wait 5-30 minutes and try again.

---

## Step 9: Install Nginx

### 9.1 Update Package List

```bash
apt update
```

### 9.2 Install Nginx and Certbot

```bash
apt install -y nginx certbot python3-certbot-nginx
```

### 9.3 Verify Installation

```bash
nginx -v
certbot --version
```

**Expected Output:**
```
nginx version: nginx/1.28.0
certbot 4.0.0
```

### 9.4 Check Nginx Status

```bash
systemctl status nginx
```

**Expected Output:**
```
● nginx.service - A high performance web server and a reverse proxy server
     Loaded: loaded (/usr/lib/systemd/system/nginx.service; enabled; preset: enabled)
     Active: active (running) since Mon 2026-01-12 18:39:48 UTC
```

---

## Step 10: Configure Reverse Proxy

### 10.1 Create Nginx Configuration File

```bash
nano /etc/nginx/sites-available/ai.innovatehub.site
```

### 10.2 Add Configuration

Paste the following content (replace `ai.innovatehub.site` with your domain):

```nginx
server {
    listen 80;
    listen [::]:80;
    server_name ai.innovatehub.site;

    # Allow Let's Encrypt challenge
    location /.well-known/acme-challenge/ {
        root /var/www/html;
    }

    # Proxy all other requests to Pareng Boyong
    location / {
        proxy_pass http://localhost:50002;
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
    }
}
```

Save and exit (Ctrl+X, Y, Enter).

### 10.3 Enable the Site

```bash
ln -s /etc/nginx/sites-available/ai.innovatehub.site /etc/nginx/sites-enabled/
```

### 10.4 Test Nginx Configuration

```bash
nginx -t
```

**Expected Output:**
```
nginx: the configuration file /etc/nginx/nginx.conf syntax is ok
nginx: configuration file /etc/nginx/nginx.conf test is successful
```

### 10.5 Restart Nginx

```bash
systemctl restart nginx
```

### 10.6 Verify Nginx is Running

```bash
systemctl status nginx
```

### 10.7 Test HTTP Access

```bash
curl -I http://ai.innovatehub.site
```

**Expected Output:**
```
HTTP/1.1 200 OK
Server: nginx/1.28.0
...
```

---

## Step 11: Setup SSL Certificate

### 11.1 Obtain SSL Certificate

```bash
certbot --nginx -d ai.innovatehub.site --non-interactive --agree-tos --email admin@innovatehub.site --redirect
```

**Command Explanation:**
- `--nginx`: Use Nginx plugin
- `-d ai.innovatehub.site`: Domain name
- `--non-interactive`: Don't prompt for input
- `--agree-tos`: Agree to Terms of Service
- `--email`: Contact email for expiration notices
- `--redirect`: Set up HTTP to HTTPS redirect

**Expected Output:**
```
Requesting a certificate for ai.innovatehub.site

Successfully received certificate.
Certificate is saved at: /etc/letsencrypt/live/ai.innovatehub.site/fullchain.pem
Key is saved at:         /etc/letsencrypt/live/ai.innovatehub.site/privkey.pem
This certificate expires on 2026-04-12.

Deploying certificate
Successfully deployed certificate for ai.innovatehub.site to /etc/nginx/sites-enabled/ai.innovatehub.site
Congratulations! You have successfully enabled HTTPS on https://ai.innovatehub.site
```

### 11.2 Verify Certificate

```bash
certbot certificates
```

**Expected Output:**
```
Found the following certs:
  Certificate Name: ai.innovatehub.site
    Serial Number: ...
    Key Type: RSA
    Domains: ai.innovatehub.site
    Expiry Date: 2026-04-12 ... (VALID: 89 days)
    Certificate Path: /etc/letsencrypt/live/ai.innovatehub.site/fullchain.pem
    Private Key Path: /etc/letsencrypt/live/ai.innovatehub.site/privkey.pem
```

### 11.3 Verify Auto-Renewal

```bash
systemctl status certbot.timer
```

**Expected Output:**
```
● certbot.timer - Run certbot twice daily
     Loaded: loaded (/usr/lib/systemd/system/certbot.timer; enabled; preset: enabled)
     Active: active (waiting)
```

### 11.4 Test Renewal (Dry Run)

```bash
certbot renew --dry-run
```

**Expected Output:**
```
Saving debug log to /var/log/letsencrypt/letsencrypt.log

- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
Processing /etc/letsencrypt/renewal/ai.innovatehub.site.conf
- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
Account registered.
Simulating renewal of an existing certificate for ai.innovatehub.site

- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
Congratulations, all simulated renewals succeeded:
  /etc/letsencrypt/live/ai.innovatehub.site/fullchain.pem (success)
- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
```

---

## Step 12: Final Testing

### 12.1 Test HTTPS Access

```bash
curl -I https://ai.innovatehub.site
```

**Expected Output:**
```
HTTP/1.1 200 OK
Server: nginx/1.28.0
Content-Type: text/html; charset=utf-8
...
```

### 12.2 Test HTTP to HTTPS Redirect

```bash
curl -I http://ai.innovatehub.site
```

**Expected Output:**
```
HTTP/1.1 301 Moved Permanently
Server: nginx/1.28.0
Location: https://ai.innovatehub.site/
...
```

### 12.3 Verify Page Title

```bash
curl -s https://ai.innovatehub.site | grep -o "<title>.*</title>"
```

**Expected Output:**
```
<title>Innovatehub AI 'Pareng Boyong'</title>
```

### 12.4 Test from Browser

Open your web browser and visit:
```
https://ai.innovatehub.site
```

You should see:
- ✅ Secure padlock icon in address bar
- ✅ Page loads without SSL warnings
- ✅ Title shows "Innovatehub AI 'Pareng Boyong'"
- ✅ Agent Zero web interface

---

## Troubleshooting

### Issue 1: Container Won't Start

**Symptoms:**
```bash
docker ps | grep pareng-boyong
# No output
```

**Solution:**
```bash
# Check logs for errors
docker logs pareng-boyong

# If port conflict, use different port
docker rm pareng-boyong
docker run -d --name pareng-boyong -p 50003:80 -v /root/pareng-boyong-data:/a0 agent0ai/agent-zero:latest
```

### Issue 2: Cannot Access via IP

**Symptoms:**
```bash
curl http://localhost:50002
# Connection refused
```

**Solution:**
```bash
# Check if container is running
docker ps | grep pareng-boyong

# Check if port is listening
netstat -tulpn | grep 50002

# Check firewall
ufw status
ufw allow 50002/tcp

# Restart container
docker restart pareng-boyong
```

### Issue 3: DNS Not Resolving

**Symptoms:**
```bash
nslookup ai.innovatehub.site
# Server can't find ai.innovatehub.site: NXDOMAIN
```

**Solution:**
1. Check DNS settings in your DNS provider
2. Verify A record is correct
3. Wait 5-30 minutes for propagation
4. Use online DNS checker: https://dnschecker.org

### Issue 4: Certbot Fails

**Symptoms:**
```
Failed authorization procedure. ai.innovatehub.site (http-01): urn:ietf:params:acme:error:dns
```

**Solution:**
```bash
# Ensure DNS is propagated first
nslookup ai.innovatehub.site

# Ensure port 80 is accessible
ufw allow 80/tcp

# Check Nginx is serving the domain
curl http://ai.innovatehub.site

# Try again
certbot --nginx -d ai.innovatehub.site
```

### Issue 5: Page Shows "Agent Zero" Instead of "Pareng Boyong"

**Symptoms:**
Browser shows old title.

**Solution:**
```bash
# Verify file was edited
grep "Pareng Boyong" /root/pareng-boyong-data/webui/index.html

# If not found, edit again
sed -i 's/<title>Agent Zero<\/title>/<title>Innovatehub AI '\''Pareng Boyong'\''<\/title>/g' /root/pareng-boyong-data/webui/index.html

# Restart container
docker restart pareng-boyong

# Clear browser cache (Ctrl+Shift+Delete)
# Or use incognito/private mode
```

### Issue 6: Nginx Configuration Error

**Symptoms:**
```
nginx: [emerg] duplicate location "/" in /etc/nginx/sites-enabled/default:50
```

**Solution:**
```bash
# Disable default site
rm /etc/nginx/sites-enabled/default

# Test configuration
nginx -t

# Restart Nginx
systemctl restart nginx
```

---

## Post-Installation

### Configure API Keys

1. Edit the .env file:
```bash
nano /root/pareng-boyong-data/.env
```

2. Add your API keys:
```env
OPENAI_API_KEY=sk-your-key-here
ANTHROPIC_API_KEY=sk-ant-your-key-here
```

3. Restart container:
```bash
docker restart pareng-boyong
```

### Setup Firewall (If Not Already Done)

```bash
# Install UFW if needed
apt install -y ufw

# Allow SSH (IMPORTANT - don't lock yourself out!)
ufw allow 22/tcp

# Allow HTTP and HTTPS
ufw allow 80/tcp
ufw allow 443/tcp

# Enable firewall
ufw enable

# Check status
ufw status
```

### Setup Automatic Backups

```bash
# Create backup script
cat > /root/backup-pareng-boyong.sh << 'EOF'
#!/bin/bash
BACKUP_DIR="/root/backups"
DATE=$(date +%Y%m%d_%H%M%S)
mkdir -p $BACKUP_DIR
tar -czf $BACKUP_DIR/pareng-boyong-data-$DATE.tar.gz /root/pareng-boyong-data
# Keep only last 7 backups
ls -t $BACKUP_DIR/pareng-boyong-data-*.tar.gz | tail -n +8 | xargs -r rm
echo "Backup completed: $DATE"
EOF

# Make executable
chmod +x /root/backup-pareng-boyong.sh

# Add to crontab (daily at 2 AM)
(crontab -l 2>/dev/null; echo "0 2 * * * /root/backup-pareng-boyong.sh") | crontab -
```

---

## Summary

You have successfully:

✅ Cloned the Pareng Boyong repository
✅ Installed Docker
✅ Pulled the Agent Zero Docker image
✅ Created persistent data directory
✅ Ran the Docker container
✅ Applied Pareng Boyong rebranding
✅ Configured domain DNS
✅ Installed Nginx reverse proxy
✅ Obtained SSL certificate from Let's Encrypt
✅ Configured automatic HTTPS redirect
✅ Verified complete installation

**Your Pareng Boyong AI Assistant is now live at:**
**https://ai.innovatehub.site**

---

## Quick Reference Commands

```bash
# Container Management
docker ps                                    # List running containers
docker logs pareng-boyong                   # View logs
docker restart pareng-boyong                # Restart container
docker stop pareng-boyong                   # Stop container
docker start pareng-boyong                  # Start container

# Nginx Management
systemctl status nginx                      # Check status
systemctl restart nginx                     # Restart Nginx
nginx -t                                    # Test configuration

# SSL Certificate
certbot certificates                        # List certificates
certbot renew                              # Renew certificates
systemctl status certbot.timer             # Check auto-renewal

# System Monitoring
docker stats pareng-boyong                 # Container resources
htop                                       # System resources
df -h                                      # Disk space
free -h                                    # Memory usage
```

---

**Installation Guide Version:** 1.0
**Last Updated:** 2026-01-12
**Tested On:** Ubuntu 24.10, Docker 29.1.3

---

*For support, visit: https://github.com/innovatehubph/pareng-boyong/issues*
