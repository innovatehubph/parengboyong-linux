#!/bin/bash
#
# PARENG BOYONG PRODUCTION RESTORE SCRIPT
# Created: 2026-01-13 03:03:08 UTC
# Backup ID: backup_20260113_030308
#
# This script restores Pareng Boyong to the exact working state
# before Omnara integration attempts.
#
# CRITICAL: This backup captures the WORKING production system at:
# - URL: https://ai.innovatehub.site
# - Status: Fully operational, tested, and deployed
# - Features: All 18 tools working, rebranding complete
#

set -e  # Exit on error

BACKUP_DIR="/root/pareng-boyong-backups/backup_20260113_030308"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)

echo "=========================================="
echo "PARENG BOYONG PRODUCTION RESTORE"
echo "=========================================="
echo "Backup from: 2026-01-13 03:03:08 UTC"
echo "Starting restore at: $(date)"
echo ""

# Function to prompt for confirmation
confirm() {
    read -p "⚠️  WARNING: This will REPLACE your current production system. Continue? (yes/no): " response
    if [ "$response" != "yes" ]; then
        echo "❌ Restore cancelled."
        exit 1
    fi
}

# Confirm with user
confirm

echo ""
echo "Step 1/6: Stopping Docker container..."
docker stop pareng-boyong || true
echo "✅ Container stopped"

echo ""
echo "Step 2/6: Creating pre-restore backup of current state..."
mkdir -p /root/pareng-boyong-backups/pre-restore_${TIMESTAMP}
tar -czf /root/pareng-boyong-backups/pre-restore_${TIMESTAMP}/current-state.tar.gz \
    /root/pareng-boyong/ \
    /root/pareng-boyong-data/ \
    2>/dev/null || true
echo "✅ Current state backed up to: /root/pareng-boyong-backups/pre-restore_${TIMESTAMP}/"

echo ""
echo "Step 3/6: Restoring production codebase..."
rm -rf /root/pareng-boyong.old 2>/dev/null || true
mv /root/pareng-boyong /root/pareng-boyong.old 2>/dev/null || true
cd /root
tar -xzf ${BACKUP_DIR}/pareng-boyong-codebase.tar.gz
echo "✅ Codebase restored"

echo ""
echo "Step 4/6: Restoring data directory..."
rm -rf /root/pareng-boyong-data.old 2>/dev/null || true
mv /root/pareng-boyong-data /root/pareng-boyong-data.old 2>/dev/null || true
tar -xzf ${BACKUP_DIR}/pareng-boyong-data.tar.gz
echo "✅ Data directory restored"

echo ""
echo "Step 5/6: Restoring Nginx configuration..."
cp ${BACKUP_DIR}/nginx-ai.innovatehub.site.conf /etc/nginx/sites-available/ai.innovatehub.site
nginx -t
systemctl reload nginx
echo "✅ Nginx configuration restored"

echo ""
echo "Step 6/6: Restarting Docker container..."
docker start pareng-boyong
sleep 5
docker ps | grep pareng-boyong
echo "✅ Container restarted"

echo ""
echo "=========================================="
echo "✅ RESTORE COMPLETE"
echo "=========================================="
echo ""
echo "Restored system state:"
echo "- Production codebase: /root/pareng-boyong/"
echo "- Data directory: /root/pareng-boyong-data/"
echo "- Nginx config: /etc/nginx/sites-available/ai.innovatehub.site"
echo "- Container: pareng-boyong (running)"
echo ""
echo "Previous state saved to:"
echo "- /root/pareng-boyong.old/"
echo "- /root/pareng-boyong-data.old/"
echo "- /root/pareng-boyong-backups/pre-restore_${TIMESTAMP}/"
echo ""
echo "🌐 Test the site: https://ai.innovatehub.site"
echo ""
echo "📋 To view logs:"
echo "   docker logs -f pareng-boyong"
echo ""
echo "=========================================="
