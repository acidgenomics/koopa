#!/usr/bin/sh

# Platform variables

# https://unix.stackexchange.com/questions/23833
# https://unix.stackexchange.com/questions/432816
# https://stackoverflow.com/questions/20007288

# Useful files to parse:
# > cat /etc/os-release
# > cat /proc/version

# Get OS name from `/etc/os-release`:
# - `-F=`: Tell awk to use = as separator.
# - `$1=="ID"`: Filter on ID.
# - `{ print $2 ;}`: Print value.

# Strip quotes:
# > sed 's/"//g'
# > tr -d \"
# > tr -cd '[:alnum:]'



# Operating system                                                          {{{1
# ==============================================================================

KOOPA_OS_NAME="$( \
    awk -F= '$1=="ID" { print $2 ;}' /etc/os-release | \
    tr -cd '[:alnum:]' \
)"
export KOOPA_OS_NAME

KOOPA_OS_VERSION="$( \
    awk -F= '$1=="VERSION_ID" { print $2 ;}' /etc/os-release | \
    tr -cd '[:digit:].' \
)"
export KOOPA_OS_VERSION



# Hostname                                                                  {{{1
# ==============================================================================

[ -z "$HOSTNAME" ] && HOSTNAME="$(uname -n)" && export HOSTNAME
case "$HOSTNAME" in
                  azlabapp*) export AZURE=1;;
    *.o2.rc.hms.harvard.edu) export HARVARD_O2=1;;
       *.rc.fas.harvard.edu) export HARVARD_ODYSSEY=1;;
                          *) ;;
esac



# vim: fdm=marker
