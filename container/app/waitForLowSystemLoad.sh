#!/usr/bin/env bash

if [ "$waitForLowSystemLoad" == "false" ]; then
    echo "Waiting for low system load disabled, starting immediately..."
    exit 0;
fi

#
#
# A service demands 2 free CPU cores to start, so it will measure CPU load and calculate if there
# is already 2 idle cores. If not, it will wait a few seconds.
#
# After X seconds wait, will try again, but if still not 2 full CPUs available, it will accept
# 0.9 * 2 CPU's. If not available, will wait again and accept 0.9 * 0.9 * 2  CPUs, and so on.
#
# By default, the time between checks is 10 seconds (+ some random offset), the ratio of
# expectations reduction between checks is 0.9, and the initial amount of CPUs expected is 2.
#
#

getFreeCpus()
{
    totalCpus=$(grep processor /proc/cpuinfo | wc -l)
    averageIdle=$(mpstat 2 1 | grep Average | grep -oE '[^ ]+$' | tr , . | grep -v idle )
    #load=$(cat /proc/loadavg | cut -d\  -f1)
    freeCpus=$(echo "$totalCpus * $averageIdle * 0.01000 " | bc)
    echo "[waitForLowSystemLoad] Total CPUS: $totalCpus, Idle time: $averageIdle%, That's $freeCpus free CPU cores."
}

isAmountOfCpusOverExpectation()
{
    getFreeCpus
    return $(echo "$freeCpus > $cpuExpectation" | bc)
}

backoffTimeSeconds=${lowSystemLoadBackoffTimeSeconds:-10}
backoffRefusalRate=${lowSystemLoadBackoffRefusalRate:-0.90000}
cpuExpectation=${lowSystemLoadCpuExpectation:-2.00000}

waitTime=$( echo "$(( (RANDOM % ($backoffTimeSeconds) )  + 1 ))" | bc )
echo "[waitForLowSystemLoad] Waiting $waitTime seconds..."
sleep ${waitTime}
isAmountOfCpusOverExpectation
expectationMet=$?
while [ ${expectationMet} == 0 ]
 do
    waitTime=$( echo "$backoffTimeSeconds + $(( (RANDOM % $backoffTimeSeconds )  + 1 ))" | bc )
    echo "[waitForLowSystemLoad] Waiting $waitTime seconds until at least $cpuExpectation CPU cores are free. Right now only $freeCpus CPU cores are free."
    sleep ${waitTime}
    cpuExpectation=$(echo "$cpuExpectation * $backoffRefusalRate" | bc)
    echo "[waitForLowSystemLoad] Reducing expectation to $cpuExpectation free CPU cores. Will continue startup when this expectation is met."
    isAmountOfCpusOverExpectation
    expectationMet=$?
 done

echo "[waitForLowSystemLoad] Expecting $cpuExpectation free CPUs, $freeCpus are available."
echo "[waitForLowSystemLoad] Continuing startup..."

