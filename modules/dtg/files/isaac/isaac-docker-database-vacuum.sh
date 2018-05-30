#!/bin/bash

echo "Started vacuum at $(date "+%Y-%m-%d %l:%M:%S")"

docker exec pg-live psql -U rutherford -c "VACUUM ANALYSE;"

echo "Finished vacuum at $(date "+%Y-%m-%d %l:%M:%S")"
echo -e "\n\n\n"
