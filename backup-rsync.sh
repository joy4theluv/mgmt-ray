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

if [ -z "$OLD_LOCAL" ]; then
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


sleep $(( RANDOM % 300 )) # Sleep for a random duration between 0 and 300 seconds (5 minutes) to avoid simultaneous rsync operations if multiple backups are running at the same time.

echo "==> Syncing backup to remote server..."

if rsync -avz "$BACKUP_DIR" <REMOTE_USER>@<REMOTE_HOST>:<REMOTE_BACKUP_DIR> ; then
    echo "==> Backup synced successfully."
else
    echo "WARNING: rsync failed. Continuing anyway."
fi


echo "==> Checking for old remote Xray backups..."

if ssh <REMOTE_USER>@<REMOTE_HOST> \
 'find <REMOTE_BACKUP_DIR> -maxdepth 1 -type d -name "xray-backup-*" -mtime +1 | grep -q .' ; then # Check if there are any old remote backups older than 1 day

    echo "==> Old remote backups found. Deleting..."

    if ssh <REMOTE_USER>@<REMOTE_HOST> \
     'find <REMOTE_BACKUP_DIR> -maxdepth 1 -type d -name "xray-backup-*" -mtime +1 -exec rm -rf {} \;' ; then # Delete old remote backups
        echo "==> Remote old backups deleted successfully."
    else
        echo "WARNING: Remote deletion failed. Continuing anyway."
    fi

else
    echo "==> No old remote backups found. Skipping deletion."
fi

echo "==> Backup process completed successfully."

#59 23 * * * /usr/local/bin/backup.sh - crontab entry to run the backup script daily at 23:59