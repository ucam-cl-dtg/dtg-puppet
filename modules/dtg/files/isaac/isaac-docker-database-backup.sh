#!/bin/bash

# Requires 'backups' and 'latest' directories to be available
# Dump the live DB, pipe into gzip, and place in local backup directory


echo "Started isaac db backup at `date "+%Y-%m-%d %l:%M"`"
BACKUP_FILE="/local/data/database-backup/backups/isaac-live-db-`date +%Y-%m-%d`.sql.gz"

/local/src/isaac-api/src/main/resources/db_scripts/dump-db.sh live | gzip > $BACKUP_FILE 
chown isaac:isaac $BACKUP_FILE

# Copy the latest
rm /local/data/database-backup/latest/*
cp $BACKUP_FILE /local/data/database-backup/latest

# Removes backups that are older than 10 days
find "/local/data/database-backup/backups" -type f -prune -mtime +10 -exec rm -f {} \;