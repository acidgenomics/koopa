#!/bin/sh
# shellcheck disable=SC2039



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



# Updated 2019-08-17.
_koopa_os_type_prompt_string() {
    local id
    local string
    local version
    
    if _koopa_is_darwin
    then
        string="$(_koopa_macos_version_short)"
    elif _koopa_is_linux
    then
        id="$( \
            awk -F= '$1=="ID" { print $2 ;}' /etc/os-release | \
            tr -d '"' \
        )"
        version="$( \
            awk -F= '$1=="VERSION_ID" { print $2 ;}' /etc/os-release | \
            tr -d '"' \
        )"
        string="${id} ${version}"
    else
        string=""
    fi
    
    if _koopa_is_remote
    then
        host_type="$(_koopa_host_type)"
        if [ -n "$host_type" ]
        then
            string="${host_type} ${string1}"
        fi
    fi
    
    echo "$string"
}



# Updated 2019-06-22.
# Note that this returns Darwin version information for macOS.
_koopa_os_version() {
    uname -r
}
