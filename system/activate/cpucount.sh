#!/bin/ssh
# shellcheck disable=SC2236

# Count CPUs for Make jobs.

if [ ! -z "$MACOS" ]
then
    CPUCOUNT="$(sysctl -n hw.ncpu)"
elif [ ! -z "$LINUX" ]
then
    CPUCOUNT="$(getconf _NPROCESSORS_ONLN)"
else
    CPUCOUNT=1
fi
export CPUCOUNT
