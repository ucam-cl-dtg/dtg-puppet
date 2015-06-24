#/bin/bash

# Location to place backups.
POSTGRES_BACKUP_DIR="/local/data/rutherford/database-backup/postgresql/"
POSTGRES_TMP_BACKUP_DIR=$POSTGRES_BACKUP_DIR"tmp"
TAR_BIN_PATH="$(which tar)"

#String to append to the name of the backup files
backup_date=`date +%d-%m-%Y`

#Numbers of days you want to keep copy of your databases
DAYS_TO_KEEP_BACKUPS=30
databases=`psql -l -t | cut -d'|' -f1 | sed -e 's/ //g' -e '/^$/d'`

#Clean and make a tmp dir
if [ -d $POSTGRES_TMP_BACKUP_DIR ]; then
	rm -Rf $POSTGRES_TMP_BACKUP_DIR
fi
mkdir $POSTGRES_TMP_BACKUP_DIR

cd $POSTGRES_BACKUP_DIR

#Iterate through databases ignoring template0 and template1
for i in $databases; do
  if [ "$i" != "template0" ] && [ "$i" != "template1" ]; then
  	backuppath=$POSTGRES_BACKUP_DIR"/"$i\_$backup_date
  	tmppath=$POSTGRES_TMP_BACKUP_DIR"/"$i\_$backup_date
    echo Dumping $i to $tmppath
    pg_dump -Fc $i > $tmppath

    if [ -f "$tmppath" ]; then
    	echo "=> Success: saved "$i"to `du -sh $tmppath`"; echo;
    else
    	echo "=> Error: did not save to `$tmppath`"; echo;
    fi

  fi
done


#Create zip of files in tmp directory
FILE_NAME="postgres-"$backup_date
$TAR_BIN_PATH --remove-files -czf $FILE_NAME.tar.gz "tmp" >> /dev/null

if [ -f $POSTGRES_FILE_NAME.tar.gz ]; then
	echo "=> Success: File "$POSTGRES_FILE_NAME".tar.gz successfully saved"
fi

#Remove old zips after the specified time period
find $backup_dir -type f -prune -mtime +$DAYS_TO_KEEP_BACKUPS -exec rm -f {} \;
