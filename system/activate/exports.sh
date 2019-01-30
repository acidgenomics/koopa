#!/bin/ssh

export KOOPA_VERSION="0.2.7"
export KOOPA_DATE="2019-01-30"

# Platform information.
# Note that this requires Python.
KOOPA_PLATFORM="$( python -mplatform )"
export KOOPA_PLATFORM

# Check if this is an interactive shell.
echo "$-" | grep -q "i" && export INTERACTIVE=1

# Fix systems missing $USER.
[ -z "$USER" ] && USER="$(whoami)" && export USER

# Current date (e.g. 2018-01-01).
# Alternatively, can use `%F`.
TODAY=$(date +%Y-%m-%d)
export TODAY

# R environmental variables.
export R_DEFAULT_PACKAGES="stats,graphics,grDevices,utils,datasets,methods,base"

