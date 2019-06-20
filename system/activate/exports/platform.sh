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

# KOOPA_OS_BUILD_STRING.
# Use this for configure --build flag.
#    AWS: x86_64-amzn-linux-gnu
# RedHat: x86_64-redhat-linux-gnu
# Darwin: x86_64-darwin15.6.0

# bash (and zsh) set useful OSTYPE variable.
[ -z "${OSTYPE:-}" ] && OSTYPE=$(bash -c "echo $OSTYPE") && export OSTYPE

mach="$(uname -m)"
os="$(uname -s)"
rev="$(uname -r)"

if [ "$os" = "Darwin" ]
then
    # KOOPA_OS_NAME="$(sw_vers -productName)"
    KOOPA_OS_NAME="darwin"
    KOOPA_OS_VERSION="$(sw_vers -productVersion)"
    KOOPA_OS_BUILD_STRING="${mach}-${OSTYPE}"
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
    # This will distinguish between RedHat, Amazon, etc.
    KOOPA_OS_BUILD_STRING="${mach}-${KOOPA_OS_NAME}-${OSTYPE}"
fi

export KOOPA_OS_BUILD_STRING
export KOOPA_OS_NAME
export KOOPA_OS_VERSION

unset -v mach os rev

KOOPA_OS_PLATFORM="$(python -mplatform)" && export KOOPA_OS_PLATFORM



# Hostname                                                                  {{{1
# ==============================================================================

[ -z "${HOSTNAME:-}" ] && HOSTNAME="$(uname -n)" && export HOSTNAME
case "$HOSTNAME" in
             *.ec2.internal) export KOOPA_HOST_NAME="aws";;
                  azlabapp*) export KOOPA_HOST_NAME="azure";;
    *.o2.rc.hms.harvard.edu) export KOOPA_HOST_NAME="harvard-o2";;
       *.rc.fas.harvard.edu) export KOOPA_HOST_NAME="harvard-odyssey";;
                          *) ;;
esac



# Build variables                                                           {{{1
# ==============================================================================

KOOPA_BUILD_PREFIX="$(build_prefix)" && export KOOPA_BUILD_PREFIX

export KOOPA_CELLAR_PREFIX="${KOOPA_DIR}/cellar"
mkdir -p "$KOOPA_CELLAR_PREFIX"

export KOOPA_TMP_DIR="${XDG_RUNTIME_DIR}/koopa"
mkdir -p "$KOOPA_TMP_DIR"



# Local configuration                                                       {{{1
# ==============================================================================

export KOOPA_CONFIG_DIR="${XDG_CONFIG_HOME}/koopa"
mkdir -p "$KOOPA_CONFIG_DIR"
update_xdg_config
