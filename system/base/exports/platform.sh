#!/usr/bin/sh

# Platform variables

# https://unix.stackexchange.com/questions/23833
# https://unix.stackexchange.com/questions/432816
# https://stackoverflow.com/questions/20007288

# Useful files to parse:
# > cat /etc/os-release
# > cat /proc/version

# For macOS, use this approach instead for OS variables:
# https://apple.stackexchange.com/questions/255546

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

os="$(uname -s)"
# rev="$(uname -r)"
# mach="$(uname -m)"

if [ "$os" = "Darwin" ]
then
    OIFS="$IFS"
    IFS=$'\n'
    set $(sw_vers) > /dev/null
    KOOPA_OS_NAME="$(echo $1 | tr "\n" ' ' | sed 's/ProductName:[ ]*//')"
    KOOPA_OS_VERSION="$(echo $2 | tr "\n" ' ' | sed 's/ProductVersion:[ ]*//')"
    IFS="$OIFS"
else
    os_file="/etc/os-release"
    KOOPA_OS_NAME="$( \
        awk -F= '$1=="ID" { print $2 ;}' "$os_file" | \
        tr -cd '[:alnum:]' \
    )"
    KOOPA_OS_VERSION="$( \
        awk -F= '$1=="VERSION_ID" { print $2 ;}' "$os_file" | \
        tr -cd '[:digit:].' \
    )"
    unset -v os_file
fi

export KOOPA_OS_NAME
export KOOPA_OS_VERSION

unset -v os



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
