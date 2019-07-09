#!/bin/sh
# shellcheck disable=SC2039

# Functions required for `koopa` script functionality.
# Modified 2019-07-09.



# Notes                                                                     {{{1
# ==============================================================================

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

# macOS version: currently, use of `sw_vers` is recommended.
#
# Alternatively, can parse this file directly instead:
# /System/Library/CoreServices/SystemVersion.plist

# See also:
# - https://unix.stackexchange.com/questions/23833
# - https://unix.stackexchange.com/questions/432816
# - https://stackoverflow.com/questions/20007288
# - https://gist.github.com/scriptingosx/670991d7ec2661605f4e3a40da0e37aa
# - https://apple.stackexchange.com/questions/255546



# Functions                                                                 {{{1
# ==============================================================================

# Build string for `make` configuration.
# Use this for `configure --build` flag.
#
# - AWS:    x86_64-amzn-linux-gnu
# - RedHat: x86_64-redhat-linux-gnu
# - Darwin: x86_64-darwin15.6.0
#
# Modified 2019-07-09.
_koopa_build_os_string() {
    local mach
    local os_type
    local string

    mach="$(uname -m)"
    
    if _koopa_is_darwin
    then
        string="${mach}-${OSTYPE}"
    elif _koopa_is_linux
    then
        # This will distinguish between RedHat, Amazon, and other distros
        # instead of just returning "linux". Note that we're substituting
        # "redhat" instead of "rhel" here, when applicable.
        os_type="$(koopa os-type)"
        if echo "$os_type" | grep -q "rhel"
        then
            os_type="redhat"
        fi
        string="${mach}-${os_type}-${OSTYPE}"
    fi

    echo "$string"
}



# Return the installation prefix to use.
# Modified 2019-06-27.
_koopa_build_prefix() {
    local prefix

    if _koopa_is_shared && _koopa_has_sudo
    then
        if echo "$KOOPA_HOME" | grep -Eq "^/opt/"
        then
            prefix="${KOOPA_HOME}/local"
        else
            prefix="/usr/local"
        fi
    else
        prefix="${HOME}/.local"
    fi

    echo "$prefix"
}



# Avoid setting to `/usr/local/cellar`, as this can conflict with Homebrew.
# Modified 2019-06-27.
_koopa_cellar_prefix() {
    local prefix

    if [ -w "$KOOPA_HOME" ]
    then
        prefix="${KOOPA_HOME}/cellar"
    else
        prefix="${XDG_DATA_HOME}/koopa/cellar"
    fi

    echo "$prefix"
}



# Modified 2019-06-27.
_koopa_conda_prefix() {
    local prefix

    if [ -w "$KOOPA_HOME" ]
    then
        prefix="${KOOPA_HOME}/conda"
    else
        prefix="${XDG_DATA_HOME}/koopa/conda"
    fi

    echo "$prefix"
}



# Source script header.
# Modified 2019-06-27.
_koopa_header() {
    local path

    if [ -z "${1:-}" ]
    then
        >&2 cat << EOF
error: TYPE argument missing.
usage: koopa header TYPE

shell:
    - bash
    - zsh

os type:
    - darwin
    - linux
        - debian
            - ubuntu
        - fedora
            - [rhel]
                - amzn

host type:
    - azure
    - harvard-o2
    - harvard-odyssey
EOF

        return 1
    fi
    
    case "$1" in
        # shell
        bash)
            path="${KOOPA_HOME}/shell/bash/include/header.sh"
            ;;
        zsh)
            path="${KOOPA_HOME}/shell/zsh/include/header.sh"
            ;;

        # os
        darwin)
            path="${KOOPA_HOME}/os/darwin/include/header.sh"
            ;;
        linux)
            path="${KOOPA_HOME}/os/linux/include/header.sh"
            ;;
            debian)
                path="${KOOPA_HOME}/os/debian/include/header.sh"
                ;;
                ubuntu)
                    path="${KOOPA_HOME}/os/ubuntu/include/header.sh"
                    ;;
            fedora)
                path="${KOOPA_HOME}/os/fedora/include/header.sh"
                ;;
                amzn)
                    path="${KOOPA_HOME}/os/amzn/include/header.sh"
                    ;;

        # host
        azure)
            path="${KOOPA_HOME}/host/azure/include/header.sh"
            ;;
        harvard-o2)
            path="${KOOPA_HOME}/host/harvard-o2/include/header.sh"
            ;;
        harvard-odyssey)
            path="${KOOPA_HOME}/host/harvard-odyssey/include/header.sh"
            ;;

        *)
            >&2 printf "Error: '%s' is not supported.\n" "$1"
            return 1
            ;;
    esac
    
    echo "$path"
}



# Simple host type name string to load up host-specific scripts.
# Currently intended support AWS, Azure, and Harvard clusters.
# Modified 2019-06-27.
_koopa_host_type() {
    local name
    case "$HOSTNAME" in
        # VMs
        *.ec2.internal)
            name="aws"
            ;;
        azlabapp*)
            name="azure"
            ;;
        # HPCs
        *.o2.rc.hms.harvard.edu)
            name="harvard-o2"
            ;;
        *.rc.fas.harvard.edu)
            name="harvard-odyssey"
            ;;
        *)
            name=
            ;;
    esac
    echo "$name"
}



# Modified 2019-06-25.
_koopa_is_local() {
    echo "$KOOPA_HOME" | grep -Eq "^${HOME}"
}



# Modified 2019-06-25.
_koopa_is_shared() {
    ! _koopa_is_local
}



# Used by `koopa info`.
# Modified 2019-07-09.
_koopa_locate() {
    local command
    local name
    local path

    command="$1"
    name="${2:-$command}"
    path="$(_koopa_quiet_which2 "$command")"
    
    if [ -z "$path" ]
    then
        path="[missing]"
    else
        path="$(realpath "$path")"
    fi
    printf "%s: %s" "$name" "$path"
}



# Modified 2019-06-22.
_koopa_macos_version() {
    _koopa_assert_is_darwin
    printf "%s %s (%s)\n" \
        "$(sw_vers -productName)" \
        "$(sw_vers -productVersion)" \
        "$(sw_vers -buildVersion)"
}



# Modified 2019-06-25.
_koopa_os_type() {
    local name
    if _koopa_is_darwin
    then
        name="$(uname -s | tr '[:upper:]' '[:lower:]')"
    elif _koopa_is_linux
    then
        name="$( \
            awk -F= '$1=="ID" { print $2 ;}' /etc/os-release | \
            tr -cd '[:alnum:]' \
        )"
	# Include the major release version for RHEL.
	if [ "$name" = "rhel" ]
	then
        major_version="$( \
            awk -F= '$1=="VERSION_ID" { print $2 ;}' /etc/os-release | \
            tr -cd '[0-9.]' | \
            cut -d '.' -f 1
        )"
        name="${name}${major_version}"
	fi
    else
        name=
    fi
    echo "$name"
}



# Modified 2019-06-22.
_koopa_os_version() {
    uname -r
}



# Modified 2019-06-21.
_koopa_rsync_flags() {
    echo "--archive --copy-links --delete-before --human-readable --progress"
}



# Note that this isn't necessarily the default shell (`$SHELL`).
# Modified 2019-06-27.
_koopa_shell() {
    local shell
    if [ -n "${BASH_VERSION:-}" ]
    then
        shell="bash"
    elif [ -n "${KSH_VERSION:-}" ]
    then
        shell="ksh"
    elif [ -n "${ZSH_VERSION:-}" ]
    then
        shell="zsh"
    else
        >&2 cat << EOF
Error: Failed to detect supported shell.
Supported: bash, ksh, zsh.

  SHELL: ${SHELL}
      0: ${0}
      -: ${-}
EOF
        return 1
    fi
    
    echo "$shell"
}



# Create temporary directory.
#
# Note: macOS requires `env LC_CTYPE=C`.
# Otherwise, you'll see this error: `tr: Illegal byte sequence`.
# This doesn't seem to work reliably, so using timestamp instead.
#
# See also:
# - https://gist.github.com/earthgecko/3089509
#
# Modified 2019-06-27.
_koopa_tmp_dir() {
    local unique
    local dir

    unique="$(date "+%Y%m%d-%H%M%S")"
    dir="/tmp/koopa-$(id -u)-${unique}"

    mkdir -p "$dir"
    chown "$USER" "$dir"
    chmod 0775 "$dir"

    echo "$dir"
}



# Get version stored internally in versions.txt file.
# Modified 2019-06-27.
_koopa_variable() {
    local what
    local file
    local match

    what="$1"
    file="${KOOPA_HOME}/system/include/variables.txt"
    match="$(grep -E "^${what}=" "$file" || echo "")"

    if [ -n "$match" ]
    then
        echo "$match" | cut -d "\"" -f 2
    else
        >&2 printf "Error: %s not defined in %s.\n" "$what" "$file"
        return 1
    fi
}
