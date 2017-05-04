#!/bin/bash

if [ "$(whoami)" != "www-deviceanalyzer" ]; then
    echo "This script should be run as the www-deviceanalyzer user"
    exit;
fi

rm -rf /var/cache/distanalysis/analysed/*
nohup /usr/bin/java -Xmx20g -XX:GCTimeLimit=60 -XX:+UseConcMarkSweepGC -Duk.ac.cam.deviceanalyzer.archivedir=/deviceanalyzer/archive/archive -Duk.ac.cam.deviceanalyzer.brokenarchivedir=/deviceanalyzer/archive/archive-suspected-broken/ -Duk.ac.cam.deviceanalyzer.exportdir=/deviceanalyzer/export -Duk.ac.cam.deviceanalyzer.analysisdir=/var/cache/distanalysis/analysed  -Duk.ac.cam.deviceanalyzer.exportOnly=true -Duk.ac.cam.deviceanalyzer.production=true -jar /usr/local/distanalysis/DistAnalysis.jar --all --workers=6 >/tmp/distanalysis-export.log 2>&1 &

echo "Log file in /tmp/distanalysis-export"
