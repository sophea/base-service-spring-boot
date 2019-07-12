#!/usr/bin/env bash
basedir=$(dirname $0)

${basedir}/wait-for-it.sh localhost:8080 --timeout=1

if [ $? != 0 ]; then
    echo "Service doesn't seem to respond in port 8080. Considering it unhealthy."
    exit 1;
fi

healthResponse=$(curl http://localhost:8080/api/healthcheck/v1 | jq .webserverOK)

if [ "${healthResponse}" == "true" ]; then
    echo "healthResponse looks good"
else
    echo "healthResponse looks unhealthy: (databaseReachable=${healthResponse})"
    exit 1;
fi;

exit 0;
