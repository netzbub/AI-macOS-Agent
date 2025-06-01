#!/bin/bash

# Backup script for Synology NAS integration
# Optimized for Synology DS1621xs+ with 8GB RAM
# Uses BorgBackup for efficient, incremental backups

# Load environment variables
if [ -f ../.env ]; then
  set -a
  source ../.env
  set +a
else
  echo "Error: .env file not found"
  echo "Please copy .env.example to .env and edit it with your settings"
  exit 1
fi

# Configuration
BORG_REPO="${NAS_USER}@${NAS_IP}:${BACKUP_DIR}/borg"
SOURCE_DIR="$(cd .. && pwd)"
DATE=$(date +%Y-%m-%d)

# Check if BorgBackup is installed
if ! command -v borg &> /dev/null; then
    echo "BorgBackup is not installed. Please install it first:"
    echo "brew install borgbackup"
    exit 1
fi

# Create backup directories on Synology if they don't exist
echo "Setting up backup directories on Synology..."
ssh ${NAS_USER}@${NAS_IP} "mkdir -p ${BACKUP_DIR}/borg"

# Initialize Borg repository if it doesn't exist
if ! borg list ${BORG_REPO} &> /dev/null; then
    echo "Initializing Borg repository..."
    borg init --encryption=none ${BORG_REPO}
fi

# Create backup
echo "Creating backup of ${SOURCE_DIR}..."
borg create --stats --progress \
    ${BORG_REPO}::ai_projects-${DATE} \
    ${SOURCE_DIR} \
    --exclude "${SOURCE_DIR}/data/postgres" \
    --exclude "${SOURCE_DIR}/data/mongodb" \
    --exclude "${SOURCE_DIR}/data/open-webui" \
    --exclude "${SOURCE_DIR}/data/portainer" \
    --exclude "${SOURCE_DIR}/data/n8n" \
    --exclude "${SOURCE_DIR}/data/astroluma" \
    --exclude "${SOURCE_DIR}/data/agent-zero" \
    --exclude "*.log" \
    --exclude "*.tmp" \
    --exclude "*.pid" \
    --exclude "*.sock" \
    --exclude "node_modules" \
    --exclude "__pycache__" \
    --exclude ".git"

# Prune old backups (keep 7 daily, 4 weekly, 6 monthly)
echo "Pruning old backups..."
borg prune --stats \
    ${BORG_REPO} \
    --keep-daily=${BACKUP_KEEP_DAILY:-7} \
    --keep-weekly=${BACKUP_KEEP_WEEKLY:-4} \
    --keep-monthly=${BACKUP_KEEP_MONTHLY:-6}

echo "Backup completed successfully!"
echo ""
echo "Backup details:"
echo "- Repository: ${BORG_REPO}"
echo "- Archive: ai_projects-${DATE}"
echo "- Source: ${SOURCE_DIR}"
echo ""
echo "Retention policy:"
echo "- Daily backups: ${BACKUP_KEEP_DAILY:-7}"
echo "- Weekly backups: ${BACKUP_KEEP_WEEKLY:-4}"
echo "- Monthly backups: ${BACKUP_KEEP_MONTHLY:-6}"
