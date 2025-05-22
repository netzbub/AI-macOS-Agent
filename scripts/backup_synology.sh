#!/bin/bash

# Backup script for Synology NAS integration
# Optimized for Synology DS1621xs+ with 8GB RAM
# Uses BorgBackup for efficient, incremental backups

# Configuration - MODIFY THESE VALUES
NAS_USER="admin"
NAS_IP="192.168.1.x"  # Replace with your Synology IP
BACKUP_DIR="/volume1/docker_backups"
SOURCE_DIR="$HOME/ai_projects"
BORG_REPO="$NAS_USER@$NAS_IP:$BACKUP_DIR/borg"
DATE=$(date +%Y-%m-%d)

# Check if BorgBackup is installed
if ! command -v borg &> /dev/null; then
    echo "BorgBackup is not installed. Please install it first:"
    echo "brew install borgbackup"
    exit 1
fi

# Create backup directories on Synology if they don't exist
echo "Setting up backup directories on Synology..."
ssh $NAS_USER@$NAS_IP "mkdir -p $BACKUP_DIR/borg"

# Initialize Borg repository if it doesn't exist
if ! borg list $BORG_REPO &> /dev/null; then
    echo "Initializing Borg repository..."
    borg init --encryption=none $BORG_REPO
fi

# Create backup
echo "Creating backup of $SOURCE_DIR..."
borg create --stats --progress \
    $BORG_REPO::ai_projects-$DATE \
    $SOURCE_DIR \
    --exclude "$SOURCE_DIR/*/data/postgres" \
    --exclude "*.log" \
    --exclude "*.tmp"

# Prune old backups (keep 7 daily, 4 weekly, 6 monthly)
echo "Pruning old backups..."
borg prune --stats \
    $BORG_REPO \
    --keep-daily=7 \
    --keep-weekly=4 \
    --keep-monthly=6

echo "Backup completed successfully!"
echo "Backup stored at: $BORG_REPO::ai_projects-$DATE"
