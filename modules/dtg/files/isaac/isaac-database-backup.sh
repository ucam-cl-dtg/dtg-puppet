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
GLOBAL_TMP="tmp"
GLOBAL_ZIP_DIR="combined"
GLOBAL_ZIP_NAME="isaac-db-backup"$TODAYS_DATE
GLOBAL_BACKUP_PATH="/local/data/rutherford/database-backup" # do not include trailing slash


### Set server settings
MONGO_HOST="localhost"
MONGO_PORT="27017" # default mongoDb port is 27017
MONGO_USERNAME=""
MONGO_PASSWORD=""
MONGO_FILE_NAME="isaac-mongodb-backup.$TODAYS_DATE" 
MONGO_DUMP_BIN_PATH="$(which mongodump)"


# Create BACKUP_PATH directory if it does not exist
[ ! -d $GLOBAL_BACKUP_PATH ] && mkdir -p $GLOBAL_BACKUP_PATH || :

# Ensure directory exists before dumping to it
if [ -d "$GLOBAL_BACKUP_PATH" ]; then

	cd $GLOBAL_BACKUP_PATH
	
	# initialize temp backup directory
	TMP_BACKUP_DIR="./"$GLOBAL_TMP"/mongodb"
	
	echo; echo "=> Backing up Mongo Server: $MONGO_HOST:$MONGO_PORT"; echo -n '   ';
	
	# run dump on mongoDB
	if [ "$MONGO_USERNAME" != "" -a "$MONGO_PASSWORD" != "" ]; then 
		$MONGO_DUMP_BIN_PATH --host $MONGO_HOST:$MONGO_PORT -u $MONGO_USERNAME -p $MONGO_PASSWORD --out $TMP_BACKUP_DIR >> /dev/null
	else
		$MONGO_DUMP_BIN_PATH --host $MONGO_HOST:$MONGO_PORT --out $TMP_BACKUP_DIR >> /dev/null 
	fi
else
	echo "!!!=> Failed to create backup path: $GLOBAL_BACKUP_PATH"
fi


##################################################################################
# Postgres backup 
##################################################################################
POSTGRES_EXECUTE=true
if [ "$POSTGRES_EXECUTE" = true ]; then

POSTGRES_TMP_BACKUP_DIR=$GLOBAL_BACKUP_PATH"/"$GLOBAL_TMP"/postgres"

POSTGRES_DATABASES=`psql -l -t | cut -d'|' -f1 | sed -e 's/ //g' -e '/^$/d'`

#Clean and make a tmp dir
if [ -d $POSTGRES_TMP_BACKUP_DIR ]; then
	rm -Rf $POSTGRES_TMP_BACKUP_DIR
fi
mkdir $POSTGRES_TMP_BACKUP_DIR

cd $GLOBAL_BACKUP_PATH

#Iterate through databases ignoring template0 and template1
for i in $POSTGRES_DATABASES; do
  if [ "$i" != "template0" ] && [ "$i" != "template1" ]; then
  	backuppath=$GLOBAL_BACKUP_PATH"/"$i\_$TODAYS_DATE
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


fi
##################################################################################
# Zip up the results and put them in the backup dir 
##################################################################################
# check to see if mongoDb was dumped correctly


if [ -d "$GLOBAL_TMP" ]; then

	if [ -d "$GLOBAL_ZIP_DIR" ]; then
		cd $GLOBAL_ZIP_DIR

		# turn dumped files into a single tar file
		$TAR_BIN_PATH --remove-files -czf $GLOBAL_ZIP_NAME.tar.gz "../"$GLOBAL_TMP >> /dev/null

		# verify that the file was created
		if [ -f "$GLOBAL_ZIP_NAME.tar.gz" ]; then
			echo "=> Success: `du -sh $GLOBAL_ZIP_NAME.tar.gz`"; echo;

			# forcely remove if files still exist and tar was made successfully
			# this is done because the --remove-files flag on tar does not always work
			if [ -d "$GLOBAL_BACKUP_PATH/$GLOBAL_ZIP_DIR/$GLOBAL_ZIP_NAME" ]; then
				rm -rf "$GLOBAL_BACKUP_PATH/$GLOBAL_ZIP_DIR/$GLOBAL_ZIP_NAME"
			fi
		else
			 echo "!!!=> Failed to create backup file: $GLOBAL_BACKUP_PATH/$GLOBAL_ZIP_DIR/$GLOBAL_ZIP_NAME.tar.gz"; echo;
		fi
	else
		echo "!!!=> Failed to add to the dir: $GLOBAL_BACKUP_PATH/$GLOBAL_ZIP_DIR"
	fi


else 
	echo; echo "!!!=> Failed to backup mongoDB"; echo;	
fi


#Remove old zips after the specified time period
#find $GLOBAL_BACKUP_PATH -type f -prune -mtime +$DAYS_TO_KEEP_BACKUPS -exec rm -f {} \;
