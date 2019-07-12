#!/usr/bin/env bash

buildInfoFile=/app/buildInfo.txt

if [ -f ${buildInfoFile} ]; then
    head -1 ${buildInfoFile} | awk '{print $2}' | tr -d \'
else
    echo "unknown"
fi
