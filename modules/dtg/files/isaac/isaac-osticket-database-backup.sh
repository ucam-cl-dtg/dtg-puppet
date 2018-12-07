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


# Generate AES key
openssl rand -base64 128 -out "$TICKETS_BACKUP_FILE".key
# Encrypt backup with AES key
openssl enc -aes-256-cbc -salt -in "$TICKETS_BACKUP_FILE" -out "$TICKETS_BACKUP_FILE".enc -pass file:"$TICKETS_BACKUP_FILE".key
# Encrypt AES key with public key
openssl rsautl -encrypt -oaep -inkey /local/data/isaac-backup.public.pem -pubin -in "$TICKETS_BACKUP_FILE".key -out "$TICKETS_BACKUP_FILE".key.enc
# Delete plaintext files
rm -f "$TICKETS_BACKUP_FILE" "$TICKETS_BACKUP_FILE".key

# Change the backup file ownership:
chown isaac:isaac "$TICKETS_BACKUP_FILE"*

# Copy the latest:
rm /local/data/database-backup/latest/isaac-tickets-db-*
cp "$TICKETS_BACKUP_FILE"* /local/data/database-backup/latest

# Removes backups that are older than 2 days:
find "/local/data/database-backup/backups" -type f -prune -mtime +2 -exec rm -f {} \;