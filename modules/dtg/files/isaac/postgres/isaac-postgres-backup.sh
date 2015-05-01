#/bin/bash

# Location to place backups.
backup_dir="/local/data/rutherford/database-backup/postgresql/"
TMP_BACKUP_DIR=$backup_dir"tmp"
TAR_BIN_PATH="$(which tar)"

#String to append to the name of the backup files
backup_date=`date +%d-%m-%Y`

#Numbers of days you want to keep copy of your databases
number_of_days=30
databases=`psql -l -t | cut -d'|' -f1 | sed -e 's/ //g' -e '/^$/d'`

#Clean and make a tmp dir
if [ -d $TMP_BACKUP_DIR ]; then
	rm -Rf $TMP_BACKUP_DIR
fi
mkdir $TMP_BACKUP_DIR

cd $backup_dir

#Iterate through databases ignoring template0 and template1
for i in $databases; do
  if [ "$i" != "template0" ] && [ "$i" != "template1" ]; then
  	backuppath=$backup_dir"/"$i\_$backup_date
  	tmppath=$TMP_BACKUP_DIR"/"$i\_$backup_date
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

if [ -f $FILE_NAME.tar.gz ]; then
	echo "=> Success: File "$FILE_NAME".tar.gz successfully saved"
fi

#Remove old zips after the specified time period
find $backup_dir -type f -prune -mtime +$number_of_days -exec rm -f {} \;
