#!/usr/bin/sh

# Platform variables

# See also:
# - https://unix.stackexchange.com/questions/23833
# - https://unix.stackexchange.com/questions/432816
# - https://stackoverflow.com/questions/20007288

# Useful files to parse on Linux:
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

# For macOS, use this approach instead for OS variables:
# - https://gist.github.com/scriptingosx/670991d7ec2661605f4e3a40da0e37aa
# - https://apple.stackexchange.com/questions/255546
# 
# Currently, use of sw_vers is recommended.
#
# Alternatively, can parse this file directly instead:
# /System/Library/CoreServices/SystemVersion.plist



# Operating system                                                          {{{1
# ==============================================================================

os="$(uname -s)"
# rev="$(uname -r)"
# mach="$(uname -m)"

if [ "$os" = "Darwin" ]
then
    # KOOPA_OS_NAME="$(sw_vers -productName)"
    KOOPA_OS_NAME="darwin"
    KOOPA_OS_VERSION="$(sw_vers -productVersion)"
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
