#/bin/bash

#Requires 'backups' and 'latest' directories to be available

#Run a postgres dumpall, pupe into gzip, and place in local backup directory
BACKUP_FILE="/local/data/rutherford/database-backup/backups/isaac-db-backup`date +%Y-%m-%d`.sql.gz"

pg_dumpall | gzip > $BACKUP_FILE 

#Copy the latest
cp $BACKUP_FILE "/local/data/rutherford/database-backup/latest"

#Removes backups that are older than 10 days
find "/local/data/rutherford/database-backup/backups" -type f -prune -mtime +10 -exec rm -f {} \;
