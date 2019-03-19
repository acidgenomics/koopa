#!/bin/sh
# shellcheck disable=SC2236

# Get the number of cores (CPUs) available.

if [ ! -z "$MACOS" ]
then
    CPU_COUNT="$(sysctl -n hw.ncpu)"
elif [ ! -z "$LINUX" ]
then
    CPU_COUNT="$(getconf _NPROCESSORS_ONLN)"
else
    # Otherwise assume single threaded.
    CPU_COUNT=1
fi
export CPU_COUNT
