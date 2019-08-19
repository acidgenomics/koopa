#!/bin/sh
# shellcheck disable=SC2039



# Operating system name.
# Always returns lowercase, with unique names for Linux distros (e.g. "debian").
# Updated 2019-08-16.
_koopa_os_type() {
    local id
    if _koopa_is_darwin
    then
        id="$(uname -s | tr '[:upper:]' '[:lower:]')"
    elif _koopa_is_linux
    then
        id="$( \
            awk -F= '$1=="ID" { print $2 ;}' /etc/os-release | \
            tr -d '"' \
        )"
        # Include the major release version for RHEL.
        if [ "$id" = "rhel" ]
        then
            version="$( \
                awk -F= '$1=="VERSION_ID" { print $2 ;}' /etc/os-release | \
                tr -d '"' | \
                cut -d '.' -f 1
            )"
            id="${id}${version}"
        fi
    else
        id=""
    fi
    echo "$id"
}



# Updated 2019-06-22.
# Note that this returns Darwin version information for macOS.
_koopa_os_version() {
    uname -r
}
