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
ZIP_NAME="isaac-db-backup"$TODAYS_DATE
BACKUP_PATH="/local/data/rutherford/database-backup" # do not include trailing slash

### Set server settings
MONGO_HOST="localhost"
MONGO_PORT="27017" # default mongoDb port is 27017
MONGO_USERNAME=""
MONGO_PASSWORD=""
MONGO_FILE_NAME="isaac-mongodb-backup.$TODAYS_DATE" 
MONGO_DUMP_BIN_PATH="$(which mongodump)"

# Temporary folders
TMP_DIR=$BACKUP_PATH"/tmp"
MONGO_TMP_DIR=$TMP_DIR"/mongodb"
POSTGRES_TMP_DIR=$TMP_DIR"/postgres"
ZIP_DIR=$BACKUP_PATH"/combined"

# Create BACKUP_PATH directory if it does not exist
[ ! -d $BACKUP_PATH ] && mkdir -p $BACKUP_PATH

# initialise temporary folders
[ -d "$TMP_DIR" ] && rm -Rf $TMP_DIR  || mkdir -p $TMP_DIR
echo "Delete and recreated $TMP_DIR"

# initialize mongo backup directory
[ -d "$MONGO_TMP_DIR" ] && rm -Rf $MONGO_TMP_DIR  || mkdir -p $MONGO_TMP_DIR
echo "Delete and recreated $MONGO_TMP_DIR"

# initialize postgres backup directory
[ -d "$POSTGRES_TMP_DIR" ] && rm -Rf $POSTGRES_TMP_DIR  || mkdir -p $POSTGRES_TMP_DIR
echo "Delete and recreated $POSTGRES_TMP_DIR"

# initialize output backup directory
[ -d "$ZIP_DIR" ] && rm -Rf $ZIP_DIR  || mkdir -p $ZIP_DIR
echo "Delete and recreated $ZIP_DIR"


##################################################################################
# Mongodb backup 
##################################################################################

# Ensure directory exists before dumping to it
if [ -d "$BACKUP_PATH" ]; then
	cd $BACKUP_PATH

	echo; echo "=> Backing up Mongo Server: $MONGO_HOST:$MONGO_PORT"; echo -n '   ';
	
	# run dump on mongoDB
	if [ "$MONGO_USERNAME" != "" -a "$MONGO_PASSWORD" != "" ]; then 
		$MONGO_DUMP_BIN_PATH --host $MONGO_HOST:$MONGO_PORT -u $MONGO_USERNAME -p $MONGO_PASSWORD --out $MONGO_TMP_DIR >> /dev/null
	else
		$MONGO_DUMP_BIN_PATH --host $MONGO_HOST:$MONGO_PORT --out $MONGO_TMP_DIR >> /dev/null 
	fi
else
	echo "!!!=> Failed to create backup path: $BACKUP_PATH"
fi


##################################################################################
# Postgres backup 
##################################################################################

POSTGRES_DATABASES=`psql -l -t | cut -d'|' -f1 | sed -e 's/ //g' -e '/^$/d'`

#Do a dump all to get all databases
tmppath=$POSTGRES_TMP_DIR"/pg_dump_"$TODAYS_DATE".sql"
echo "Dumping all to $tmppath"
pg_dumpall > $tmppath
if [ -f "$tmppath" ]; then
	echo "=> Success: saved backup to `du -sh $tmppath`"; echo;
else
	echo "=> Error: did not save backup to `$tmppath`"; echo;
fi

##################################################################################
# Zip up the results and put them in the backup dir 
##################################################################################
# check to see if mongoDb was dumped correctly

cd $ZIP_DIR

# turn dumped files into a single tar file
echo "$TAR_BIN_PATH --remove-files -czf $ZIP_NAME.tar.gz $TMP_DIR >> /dev/null"
$TAR_BIN_PATH --remove-files -czf $ZIP_NAME.tar.gz $TMP_DIR >> /dev/null

# verify that the file was created
if [ -f "$ZIP_NAME.tar.gz" ]; then
	echo "=> Success: `du -sh $ZIP_NAME.tar.gz`"; echo;

	# forcely remove if files still exist and tar was made successfully
	# this is done because the --remove-files flag on tar does not always work
	if [ -d "$ZIP_DIR/$ZIP_NAME" ]; then
		echo "Removing : $ZIP_DIR/$ZIP_NAME"
		rm -rf "$ZIP_DIR/$ZIP_NAME"
	fi
else
	 echo "!!!=> Failed to create backup file: $ZIP_DIR/$ZIP_NAME.tar.gz"; echo;
fi


#Remove old zips after the specified time period
find $ZIP_DIR -type f -prune -mtime +$DAYS_TO_KEEP_BACKUPS -exec rm -f {} \;
