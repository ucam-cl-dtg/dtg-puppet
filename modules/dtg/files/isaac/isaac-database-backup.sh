#/bin/bash
#
# Michael Mottola
# <mikemottola@gmail.com>
# December 18, 2011
# 
# https://github.com/controlz/Mongo-db-shell-backup
#
# Modified by: Stephen Cummins (2014) - fixed a random substitution error by restructuring the script slightly.
# Modified by: Alsitair Stead (2015) - added facility for postgres backups 
# 
# Creates backup files (bson) of all MongoDb databases on a given server.
# Default behaviour dumps the mongo database and tars the output into a file
# named after the current date. ex: 2011-12-19.tar.gz
#

##################################################################################
# Mongodb backup 
##################################################################################

# Global variables
TAR_BIN_PATH="$(which tar)"
TODAYS_DATE=`date +%Y-%m-%d`
DAYS_TO_KEEP_BACKUPS=30 


### Set server settings
MONGO_HOST="localhost"
MONGO_PORT="27017" # default mongoDb port is 27017
MONGO_USERNAME=""
MONGO_PASSWORD=""

# Set where database backups will be stored
# keyword DATE gets replaced by the current date, you can use it in either path below
MONGO_BACKUP_PATH="/local/data/rutherford/database-backup/mongodb" # do not include trailing slash


MONGO_FILE_NAME="isaac-db-backup.$TODAYS_DATE" #defaults to [currentdate].tar.gz ex: 2011-12-19.tar.gz

# Auto detect unix bin paths, enter these manually if script fails to auto detect
MONGO_DUMP_BIN_PATH="$(which mongodump)"

# replace DATE with todays date in the backup path
MONGO_BACKUP_PATH="${MONGO_BACKUP_PATH}"

# Create BACKUP_PATH directory if it does not exist
[ ! -d $MONGO_BACKUP_PATH ] && mkdir -p $MONGO_BACKUP_PATH || :

# Ensure directory exists before dumping to it
if [ -d "$MONGO_BACKUP_PATH" ]; then

	cd $MONGO_BACKUP_PATH
	
	# initialize temp backup directory
	TMP_BACKUP_DIR="mongodb-$TODAYS_DATE"
	
	echo; echo "=> Backing up Mongo Server: $MONGO_HOST:$MONGO_PORT"; echo -n '   ';
	
	# run dump on mongoDB
	if [ "$MONGO_USERNAME" != "" -a "$MONGO_PASSWORD" != "" ]; then 
		$MONGO_DUMP_BIN_PATH --host $MONGO_HOST:$MONGO_PORT -u $MONGO_USERNAME -p $MONGO_PASSWORD --out $TMP_BACKUP_DIR >> /dev/null
	else 
		$MONGO_DUMP_BIN_PATH --host $MONGO_HOST:$MONGO_PORT --out $TMP_BACKUP_DIR >> /dev/null
	fi
	
	# check to see if mongoDb was dumped correctly
	if [ -d "$TMP_BACKUP_DIR" ]; then
	
		# turn dumped files into a single tar file
		$TAR_BIN_PATH --remove-files -czf $MONGO_FILE_NAME.tar.gz $TMP_BACKUP_DIR >> /dev/null

		# verify that the file was created
		if [ -f "$MONGO_FILE_NAME.tar.gz" ]; then
			echo "=> Success: `du -sh $MONGO_FILE_NAME.tar.gz`"; echo;
	
			# forcely remove if files still exist and tar was made successfully
			# this is done because the --remove-files flag on tar does not always work
			if [ -d "$MONGO_BACKUP_PATH/$TMP_BACKUP_DIR" ]; then
				rm -rf "$MONGO_BACKUP_PATH/$TMP_BACKUP_DIR"
			fi
		else
			 echo "!!!=> Failed to create backup file: $MONGO_BACKUP_PATH/$MONGO_FILE_NAME.tar.gz"; echo;
		fi
	else 
		echo; echo "!!!=> Failed to backup mongoDB"; echo;	
	fi
else

	echo "!!!=> Failed to create backup path: $MONGO_BACKUP_PATH"

fi


##################################################################################
# Postgres backup 
##################################################################################
POSTGRES_EXECUTE=true
if [ "$POSTGRES_EXECUTE" = true ]; then

POSTGRES_BACKUP_DIR="/local/data/rutherford/database-backup/postgresql/"
POSTGRES_TMP_BACKUP_DIR=$POSTGRES_BACKUP_DIR"tmp"

POSTGRES_DATABASES=`psql -U postgres -l -t | cut -d'|' -f1 | sed -e 's/ //g' -e '/^$/d'`

#Clean and make a tmp dir
if [ -d $POSTGRES_TMP_BACKUP_DIR ]; then
	rm -Rf $POSTGRES_TMP_BACKUP_DIR
fi
mkdir $POSTGRES_TMP_BACKUP_DIR

cd $POSTGRES_BACKUP_DIR

#Iterate through databases ignoring template0 and template1
for i in $POSTGRES_DATABASES; do
  if [ "$i" != "template0" ] && [ "$i" != "template1" ]; then
  	backuppath=$POSTGRES_BACKUP_DIR"/"$i\_$TODAYS_DATE
  	tmppath=$POSTGRES_TMP_BACKUP_DIR"/"$i\_$TODAYS_DATE
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
FILE_NAME="postgres-"$TODAYS_DATE
$TAR_BIN_PATH --remove-files -czf $FILE_NAME.tar.gz "tmp" >> /dev/null

if [ -f $POSTGRES_FILE_NAME.tar.gz ]; then
	echo "=> Success: File "$POSTGRES_FILE_NAME".tar.gz successfully saved"
fi

#Remove old zips after the specified time period
find $backup_dir -type f -prune -mtime +$DAYS_TO_KEEP_BACKUPS -exec rm -f {} \;
fi
