#!/bin/bash

# Requires 'backups' and 'latest' directories to be available
# Dump the live DB, pipe into gzip, and place in local backup directory

echo "Started OSTicket db backup at `date "+%Y-%m-%d %l:%M"`"
TICKETS_BACKUP_FILE="/local/data/database-backup/backups/isaac-tickets-db-`date +%Y-%m-%d`.sql.gz"

# Dump the OSTicket DB
docker exec isaac-tickets-db mysqldump -u osticket -posticket osticket | gzip > $TICKETS_BACKUP_FILE
chown isaac:isaac $TICKETS_BACKUP_FILE

# Copy the latest
rm /local/data/database-backup/latest/isaac-tickets-db-*
cp $TICKETS_BACKUP_FILE /local/data/database-backup/latest

# Removes backups that are older than 10 days
find "/local/data/database-backup/backups" -type f -prune -mtime +10 -exec rm -f {} \;
