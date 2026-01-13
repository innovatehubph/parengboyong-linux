# Pareng Boyong Authentication Setup

## Authentication Configuration

This guide explains how to configure authentication and CORS settings for Pareng Boyong.

---

## Issue: Origin Not Allowed Error

**Error Message:**
```
Origin https://ai.innovatehub.site not allowed when login is disabled.
Set login and password or add your URL to ALLOWED_ORIGINS env variable.
```

**Cause:** The application's CORS (Cross-Origin Resource Sharing) policy blocks requests from domains that aren't in the allowed origins list.

---

## Solution: Configure Authentication and CORS

### Step 1: Edit Environment File

```bash
nano /root/pareng-boyong-data/.env
```

### Step 2: Add Authentication Credentials

Add the following lines to the `.env` file:

```env
# Basic Authentication
BASIC_AUTH_USERNAME=admin
BASIC_AUTH_PASSWORD=innovatehub2026

# Allowed Origins (CORS)
ALLOWED_ORIGINS=*://localhost:*,*://127.0.0.1:*,*://0.0.0.0:*,https://ai.innovatehub.site,http://ai.innovatehub.site
```

**Explanation:**
- `BASIC_AUTH_USERNAME`: Username for login
- `BASIC_AUTH_PASSWORD`: Password for login
- `ALLOWED_ORIGINS`: Comma-separated list of allowed origins
  - `*://localhost:*` - Allow localhost with any protocol/port
  - `*://127.0.0.1:*` - Allow 127.0.0.1 with any protocol/port
  - `*://0.0.0.0:*` - Allow 0.0.0.0 with any protocol/port
  - `https://ai.innovatehub.site` - Your production domain (HTTPS)
  - `http://ai.innovatehub.site` - Your production domain (HTTP)

### Step 3: Restart Container

```bash
docker restart pareng-boyong
```

Wait 20-30 seconds for the container to fully restart.

### Step 4: Test Access

Visit your domain:
```
https://ai.innovatehub.site
```

You should now see a login prompt. Enter:
- **Username:** `admin`
- **Password:** `innovatehub2026`

---

## Adding Multiple Domains

If you need to allow multiple domains, add them to the `ALLOWED_ORIGINS` variable separated by commas:

```env
ALLOWED_ORIGINS=*://localhost:*,*://127.0.0.1:*,https://ai.innovatehub.site,https://another-domain.com,https://third-domain.com
```

---

## Changing Authentication Credentials

### Update Username and Password

1. Edit the `.env` file:
```bash
nano /root/pareng-boyong-data/.env
```

2. Change the values:
```env
BASIC_AUTH_USERNAME=newusername
BASIC_AUTH_PASSWORD=newpassword123
```

3. Restart the container:
```bash
docker restart pareng-boyong
```

---

## Disabling Authentication (Not Recommended for Production)

If you want to disable authentication entirely (only recommended for local/development use):

1. Remove or comment out the auth lines in `.env`:
```env
# BASIC_AUTH_USERNAME=admin
# BASIC_AUTH_PASSWORD=innovatehub2026
```

2. Ensure your domain is in `ALLOWED_ORIGINS`:
```env
ALLOWED_ORIGINS=*://localhost:*,*://127.0.0.1:*,https://ai.innovatehub.site
```

3. Restart:
```bash
docker restart pareng-boyong
```

⚠️ **Warning:** This will make your instance accessible to anyone without credentials!

---

## Security Best Practices

### 1. Use Strong Passwords

Don't use simple passwords. Generate strong passwords:
```bash
openssl rand -base64 24
```

Example strong password: `7X9mK2nP8qR5tU1vW3yZ4aB6cD`

### 2. Use HTTPS Only

Always use HTTPS for production. Disable HTTP in your Nginx configuration:

```nginx
# Only allow HTTPS, no HTTP
server {
    listen 80;
    server_name ai.innovatehub.site;
    return 301 https://$server_name$request_uri;
}
```

### 3. Restrict Access by IP (Optional)

In Nginx configuration, allow only specific IPs:

```nginx
location / {
    # Allow specific IPs
    allow 203.0.113.1;  # Your office IP
    allow 198.51.100.0/24;  # Your office network
    deny all;  # Deny everyone else

    proxy_pass http://localhost:50002;
    # ... rest of config
}
```

### 4. Use Environment-Specific Credentials

Don't use the same credentials for development and production:

**Development (local):**
```env
BASIC_AUTH_USERNAME=dev
BASIC_AUTH_PASSWORD=dev123
```

**Production (VPS):**
```env
BASIC_AUTH_USERNAME=admin
BASIC_AUTH_PASSWORD=7X9mK2nP8qR5tU1vW3yZ4aB6cD
```

### 5. Regularly Update Credentials

Change passwords periodically (every 3-6 months):
```bash
# Generate new password
NEW_PASSWORD=$(openssl rand -base64 24)
echo "New password: $NEW_PASSWORD"

# Update .env file
nano /root/pareng-boyong-data/.env

# Restart
docker restart pareng-boyong
```

### 6. Secure the .env File

Restrict file permissions:
```bash
chmod 600 /root/pareng-boyong-data/.env
chown root:root /root/pareng-boyong-data/.env
```

Only root can read/write:
```bash
ls -la /root/pareng-boyong-data/.env
# Output: -rw------- 1 root root ... .env
```

---

## Troubleshooting

### Issue: Still Getting CORS Error After Update

**Solution 1: Check Syntax**
```bash
grep ALLOWED_ORIGINS /root/pareng-boyong-data/.env
```

Ensure there are no typos or extra spaces.

**Solution 2: Verify Container Restart**
```bash
docker ps | grep pareng-boyong
```

Check the "STATUS" column - should show "Up X seconds/minutes" (recently restarted).

**Solution 3: Clear Browser Cache**
- Press Ctrl+Shift+Delete
- Clear cache and cookies
- Or use Incognito/Private mode

**Solution 4: Check Container Logs**
```bash
docker logs pareng-boyong --tail 50
```

Look for any error messages related to authentication.

### Issue: Can't Login with Credentials

**Check 1: Verify .env Contents**
```bash
cat /root/pareng-boyong-data/.env | grep BASIC_AUTH
```

Ensure credentials are correctly set.

**Check 2: No Extra Spaces**
```bash
# Wrong (has spaces)
BASIC_AUTH_USERNAME = admin

# Correct (no spaces)
BASIC_AUTH_USERNAME=admin
```

**Check 3: Restart Again**
```bash
docker restart pareng-boyong
sleep 20
```

### Issue: Authentication Prompt Doesn't Appear

**Possible Causes:**
1. Authentication is disabled
2. Browser cached the "no auth" state
3. Nginx is caching responses

**Solution:**
```bash
# 1. Verify auth is enabled
grep BASIC_AUTH /root/pareng-boyong-data/.env

# 2. Clear Nginx cache (if using)
nginx -s reload

# 3. Test with curl
curl -I https://ai.innovatehub.site

# Should return: HTTP/1.1 401 Unauthorized (if auth is working)
```

---

## Environment Variables Reference

### Required Variables

```env
A0_PERSISTENT_RUNTIME_ID=<auto-generated>
ROOT_PASSWORD=<auto-generated>
```

### Authentication Variables

```env
# Basic Authentication
BASIC_AUTH_USERNAME=admin
BASIC_AUTH_PASSWORD=your-secure-password

# CORS Settings
ALLOWED_ORIGINS=*://localhost:*,*://127.0.0.1:*,https://your-domain.com
```

### Optional API Keys

```env
# OpenAI
OPENAI_API_KEY=sk-...

# Anthropic
ANTHROPIC_API_KEY=sk-ant-...

# Other AI providers
GOOGLE_API_KEY=...
AZURE_OPENAI_API_KEY=...
```

---

## Complete .env Example

```env
# Runtime
A0_PERSISTENT_RUNTIME_ID=66feda3737f55c5ac3646c00590db860
ROOT_PASSWORD=qUhw9Bppw9qgQFs9rvJUyh0CD34T6DwA

# Authentication
BASIC_AUTH_USERNAME=admin
BASIC_AUTH_PASSWORD=innovatehub2026

# CORS
ALLOWED_ORIGINS=*://localhost:*,*://127.0.0.1:*,*://0.0.0.0:*,https://ai.innovatehub.site,http://ai.innovatehub.site

# AI API Keys (optional)
OPENAI_API_KEY=sk-your-openai-key
ANTHROPIC_API_KEY=sk-ant-your-anthropic-key
```

---

## Testing Authentication

### Test 1: Without Credentials (Should Fail)

```bash
curl -I https://ai.innovatehub.site
```

**Expected Output:**
```
HTTP/1.1 401 Unauthorized
WWW-Authenticate: Basic realm="Login Required"
```

### Test 2: With Wrong Credentials (Should Fail)

```bash
curl -u wronguser:wrongpass https://ai.innovatehub.site
```

**Expected Output:**
```
HTTP/1.1 401 Unauthorized
```

### Test 3: With Correct Credentials (Should Succeed)

```bash
curl -u admin:innovatehub2026 https://ai.innovatehub.site | grep "<title>"
```

**Expected Output:**
```
<title>Innovatehub AI 'Pareng Boyong'</title>
```

---

## Current Configuration

**Domain:** ai.innovatehub.site
**Authentication:** Enabled
**Username:** admin
**Password:** innovatehub2026
**Allowed Origins:**
- localhost (all ports)
- 127.0.0.1 (all ports)
- https://ai.innovatehub.site
- http://ai.innovatehub.site

---

## Quick Commands Reference

```bash
# Edit authentication settings
nano /root/pareng-boyong-data/.env

# Restart to apply changes
docker restart pareng-boyong

# View current settings
cat /root/pareng-boyong-data/.env

# Check container status
docker ps | grep pareng-boyong

# View logs
docker logs pareng-boyong --tail 50

# Test authentication
curl -u admin:innovatehub2026 https://ai.innovatehub.site

# Generate strong password
openssl rand -base64 24
```

---

**Last Updated:** 2026-01-12
**Applied To:** ai.innovatehub.site

---

*For additional security configurations, see [VPS_INSTALLATION_GUIDE.md](VPS_INSTALLATION_GUIDE.md)*
