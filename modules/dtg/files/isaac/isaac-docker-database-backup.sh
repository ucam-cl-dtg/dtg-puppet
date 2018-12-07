#!/bin/bash

# Requires 'backups' and 'latest' directories to be available
# Dump the live DB, pipe into gzip, and place in local backup directory

echo "Started isaac db backup at $(date "+%Y-%m-%d %l:%M")"
ISAAC_BACKUP_FILE="/local/data/database-backup/backups/isaac-live-db-$(date +%Y-%m-%d).sql.gz"

# Dump the Isaac DB:
/local/src/isaac-api/src/main/resources/db_scripts/dump-db.sh live | gzip > "$ISAAC_BACKUP_FILE"

# Generate AES key
openssl rand -base64 128 -out "$ISAAC_BACKUP_FILE".key
# Encrypt backup with AES key
openssl enc -aes-256-cbc -salt -in "$ISAAC_BACKUP_FILE" -out "$ISAAC_BACKUP_FILE".enc -pass file:"$ISAAC_BACKUP_FILE".key
# Encrypt AES key with public key
openssl rsautl -encrypt -oaep -inkey /local/data/isaac-backup.public.pem -pubin -in "$ISAAC_BACKUP_FILE".key -out "$ISAAC_BACKUP_FILE".key.enc
# Delete plaintext files
rm -f "$ISAAC_BACKUP_FILE" "$ISAAC_BACKUP_FILE".key


chown isaac:isaac "$ISAAC_BACKUP_FILE"*

# Copy the latest:
rm /local/data/database-backup/latest/isaac-live-db-*
cp "$ISAAC_BACKUP_FILE"* /local/data/database-backup/latest

# Removes backups that are older than 2 days:
find "/local/data/database-backup/backups" -type f -prune -mtime +2 -exec rm -f {} \;