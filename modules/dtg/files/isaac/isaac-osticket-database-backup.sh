#!/bin/bash

# Requires 'backups' and 'latest' directories to be available
# Dump the live DB, pipe into gzip, and place in local backup directory

echo "Started OSTicket db backup at $(date "+%Y-%m-%d %l:%M")"
TICKETS_BACKUP_FILE="/local/data/database-backup/backups/isaac-tickets-db-$(date +%Y-%m-%d).sql.gz"

# Dump the OSTicket DB:

#     This command requires a password on the command line, which will generate a warning email:
#docker exec isaac-tickets-db mysqldump -u osticket -posticket osticket | gzip > "$TICKETS_BACKUP_FILE"

#     This command requires a file called 'my.cnf' in '/etc/my.cnf' in the tickets docker image. The file should contain:
#          [mysqldump]
#          user=osticket
#          password=osticket
docker exec isaac-tickets-db mysqldump -u osticket osticket | gzip > "$TICKETS_BACKUP_FILE"

# Change the backup file ownership:
chown isaac:isaac "$TICKETS_BACKUP_FILE"

# Copy the latest:
rm /local/data/database-backup/latest/isaac-tickets-db-*
cp "$TICKETS_BACKUP_FILE" /local/data/database-backup/latest

# Removes backups that are older than 10 days:
find "/local/data/database-backup/backups" -type f -prune -mtime +10 -exec rm -f {} \;
