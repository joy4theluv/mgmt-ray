#!/bin/bash

DATE=$(date +%F) # Get current date
BACKUP_DIR="/root/backups/xray-backup-$DATE" # Create backup directory with current date

mkdir -p "$BACKUP_DIR" # Create the backup directory if it doesn't exist

echo "==> Backing up v2ray database..."
cp /etc/x-ui/x-ui.db "$BACKUP_DIR/" 2>/dev/null # Copy the database file to the backup directory   

if [ $? -ne 0 ]; then
    echo "ERROR: Backup creation failed. Stopping script."
    exit 1
fi

echo "==> The backup is created successfully."


echo "==> Checking for old local Xray backups..."

OLD_LOCAL=$(find /root/backups/ -maxdepth 1 -type d -name "xray-backup-*" -mtime +1) # Find old local backups older than 1 day

if [ -z "$OLD_LOCAL" ]; then #
    echo "==> No old local backups found. Skipping deletion."
else
    echo "==> Old local backups found:"
    echo "$OLD_LOCAL"

    if find /root/backups/ -maxdepth 1 -type d -name "xray-backup-*" -mtime +1 -exec rm -rf {} \; ; then # Delete old local backups
        echo "==> Old local backups deleted successfully."
    else
        echo "WARNING: Failed to delete some old local backups. Continuing anyway."
    fi
fi

#59 23 * * * /usr/local/bin/backup.sh - crontab entry to run the backup script daily at 23:59