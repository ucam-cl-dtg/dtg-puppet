#!/bin/bash

# Exit if ipcluster already running
ps xc | grep -F ipcluster && exit 0

cd /home/dwt27/ipc
source venv/bin/activate
ipcluster start -n 7
echo Started ipcluster
