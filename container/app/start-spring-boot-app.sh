#!/usr/bin/env bash

# Read possible environment files in the root folder (docker configs attached to this container).
envFiles=$(ls /*.env)
if [ "${envFiles}" != "" ]; then
    for file in ${envFiles}
    do
        echo "Including environment values from ${file}"
        cat ${file}
        echo "********"
        source ${file}
    done
fi


# Interpret the environment variables expected in the .env files (environment and main_database_host)
if [ "${environment}" != "" ]; then
    activeProfile=${environment}
fi


if [ "${application_version}" != "" ]; then
    serviceArgs="${serviceArgs} --application.version=${application_version}"
fi

#if [ "${activeProfile}" = "" ]; then
 #   echo "ERROR: An environment variable named activeProfile must be set with value DEVELOPMENT, PRODUCTION, TEST or STAGING so that spring-boot will choose the right configuration."
 #   exit 1
#fi

activeProfile=$(echo "${activeProfile}" | tr '[:lower:]' '[:upper:]')

if [ "${debuggerPort}" != "" ]; then
    javaArgs="${javaArgs} -agentlib:jdwp=transport=dt_socket,server=y,suspend=n,address=${debuggerPort}"
fi

xmx=256m
if [ "${memorySize}" != "" ]; then
    xmx=${memorySize}
fi

if [ -f "/app/beforeRunningJvm.sh" ]; then
    source /app/beforeRunningJvm.sh
fi

#source /app/waitForDependencies.sh
#source /app/waitForLowSystemLoad.sh

cd app

javaCommand="java -server\
 -Xms64m\
 -Xmx${xmx}\
 -XX:SurvivorRatio=8\
 -XX:+UseConcMarkSweepGC\
 -XX:+CMSParallelRemarkEnabled\
 -XX:+UseCMSInitiatingOccupancyOnly\
 -XX:CMSInitiatingOccupancyFraction=70\
 -XX:+ScavengeBeforeFullGC\
 -XX:+CMSScavengeBeforeRemark\
 -XX:+PrintGCDateStamps\
 -Dsun.net.inetaddr.ttl=180\
 -XX:+HeapDumpOnOutOfMemoryError\
 ${javaArgs} -jar\
 app.jar\
 --spring.profiles.active=${activeProfile} ${serviceArgs}"

if [ "${activeProfile}" = "" ]; then
javaCommand="java -server\
 -Xms32m\
 -Xmx${xmx}\
 -XX:SurvivorRatio=8\
 -XX:+UseConcMarkSweepGC\
 -XX:+CMSParallelRemarkEnabled\
 -XX:+UseCMSInitiatingOccupancyOnly\
 -XX:CMSInitiatingOccupancyFraction=70\
 -XX:+ScavengeBeforeFullGC\
 -XX:+CMSScavengeBeforeRemark\
 -XX:+PrintGCDateStamps\
 -Dsun.net.inetaddr.ttl=180\
 -XX:+HeapDumpOnOutOfMemoryError\
 ${javaArgs} -jar\
 app.jar\
 ${serviceArgs}"
fi

echo "Running ${javaCommand}"

exec ${javaCommand}
