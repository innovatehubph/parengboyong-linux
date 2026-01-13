# Pareng Boyong Production Backups

This directory contains documentation and restore scripts for production backups.

**Note:** The actual backup files (.tar.gz archives) are stored on the VPS at `/root/pareng-boyong-backups/` and are NOT committed to git due to their size (166+ MB).

---

## Available Backups

### backup_20260113_030308 (CRITICAL - Pre-Omnara Integration)

**Created:** 2026-01-13 03:03:08 UTC
**Status:** ✅ Verified Working Production System
**Purpose:** Safety backup before Omnara integration changes

**Contains:**
- Complete production codebase (61 MB)
- Data directory (53 MB)
- Nginx configuration
- Docker container config
- Git repository snapshot
- Full documentation

**Restore:**
```bash
# On VPS, run:
/root/pareng-boyong-backups/backup_20260113_030308/RESTORE.sh
```

**Files in this backup:**
- `BACKUP_SUMMARY.txt` - Quick overview
- `PRODUCTION_STATE.md` - Complete system documentation
- `QUICK_REFERENCE.txt` - Quick reference card
- `RESTORE.sh` - Automated restore script

---

## VPS Backup Locations

**Primary Backup:**
```
/root/pareng-boyong-backups/backup_20260113_030308/
```

**Secondary Copy:**
```
/root/pareng-boyong-backups/backup_20260113_030308_COPY/
```

**Total Size:** ~332 MB (166 MB × 2 copies)

---

## Backup Contents (on VPS only)

```
backup_20260113_030308/
├── pareng-boyong-codebase.tar.gz      (61 MB)  - NOT in git
├── pareng-boyong-data.tar.gz          (53 MB)  - NOT in git
├── parengboyong-linux-repo.tar.gz     (52 MB)  - NOT in git
├── nginx-ai.innovatehub.site.conf     (1.5 KB)
├── docker-container-config.json       (9.1 KB)
├── docker-status.txt                  (116 B)
├── RESTORE.sh                         (3.3 KB) - ✅ In git
├── PRODUCTION_STATE.md                (9.4 KB) - ✅ In git
├── QUICK_REFERENCE.txt                (2.5 KB) - ✅ In git
└── BACKUP_SUMMARY.txt                 (2.6 KB) - ✅ In git
```

---

## What's Backed Up

### Production System State
- **URL:** https://ai.innovatehub.site
- **Status:** Fully operational
- **Container:** pareng-boyong (Running)
- **Uptime:** 4+ hours stable

### Features
- ✅ All 18 tools working
- ✅ Filipino rebranding complete
- ✅ SSL certificate valid
- ✅ Authentication enabled
- ✅ Docker container stable

### Key Modifications
- `agent.py` - Filipino names (Pareng Boyong, Juan, Pedro, etc.)
- `python/api/message.py` - "Boss Marc" user label
- `prompts/fw.initial_message.md` - Pareng Boyong welcome
- All 18 tools and prompts

---

## How to Restore

### Option 1: Automated (Recommended)

SSH into VPS and run:
```bash
/root/pareng-boyong-backups/backup_20260113_030308/RESTORE.sh
```

### Option 2: Manual

```bash
# 1. Stop container
docker stop pareng-boyong

# 2. Restore codebase
cd /root
mv pareng-boyong pareng-boyong.old
tar -xzf /root/pareng-boyong-backups/backup_20260113_030308/pareng-boyong-codebase.tar.gz

# 3. Restore data
mv pareng-boyong-data pareng-boyong-data.old
tar -xzf /root/pareng-boyong-backups/backup_20260113_030308/pareng-boyong-data.tar.gz

# 4. Restore Nginx
cp /root/pareng-boyong-backups/backup_20260113_030308/nginx-ai.innovatehub.site.conf \
   /etc/nginx/sites-available/ai.innovatehub.site
nginx -t && systemctl reload nginx

# 5. Restart container
docker start pareng-boyong

# 6. Verify
docker logs -f pareng-boyong
```

---

## Important Notes

⚠️ **CRITICAL:**
- This backup is from a **VERIFIED WORKING SYSTEM**
- Do NOT delete backups without creating replacements
- The actual backup files are ONLY on the VPS
- Only documentation is in git (for reference)
- Always verify backup integrity before major changes

---

## Creating New Backups

```bash
# Set timestamp
TIMESTAMP=$(date +%Y%m%d_%H%M%S)

# Create backup directory
mkdir -p /root/pareng-boyong-backups/backup_${TIMESTAMP}

# Backup codebase
tar -czf /root/pareng-boyong-backups/backup_${TIMESTAMP}/pareng-boyong-codebase.tar.gz \
    /root/pareng-boyong/

# Backup data
tar -czf /root/pareng-boyong-backups/backup_${TIMESTAMP}/pareng-boyong-data.tar.gz \
    /root/pareng-boyong-data/

# Backup Nginx
cp /etc/nginx/sites-available/ai.innovatehub.site \
   /root/pareng-boyong-backups/backup_${TIMESTAMP}/nginx-ai.innovatehub.site.conf

# Export Docker config
docker inspect pareng-boyong > \
    /root/pareng-boyong-backups/backup_${TIMESTAMP}/docker-container-config.json

# Create documentation
# (See backup_20260113_030308 for template)
```

---

## Off-Site Backup (Recommended)

For disaster recovery, create off-site backups:

```bash
# Upload to S3 (example)
aws s3 sync /root/pareng-boyong-backups/ \
    s3://your-bucket/pareng-boyong-backups/

# Or upload to Google Cloud Storage
gsutil -m rsync -r /root/pareng-boyong-backups/ \
    gs://your-bucket/pareng-boyong-backups/
```

---

## Backup Schedule

**Recommended:**
- Before major changes: Manual backup
- Weekly: Automated backup
- Before updates: Manual backup
- Before experiments: Manual backup

---

## Contact

**Production:** https://ai.innovatehub.site
**GitHub:** https://github.com/innovatehubph/parengboyong-linux
**Website:** https://innovatehub.ph

---

**© 2026 InnovateHub. All rights reserved.**
