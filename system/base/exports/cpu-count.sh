#!/bin/sh
# shellcheck disable=SC2236

# Count CPUs for Make jobs.

if [ ! -z "$MACOS" ]
then
    CPU_COUNT="$(sysctl -n hw.ncpu)"
elif [ ! -z "$LINUX" ]
then
    CPU_COUNT="$(getconf _NPROCESSORS_ONLN)"
else
    CPU_COUNT=1
fi
export CPU_COUNT
