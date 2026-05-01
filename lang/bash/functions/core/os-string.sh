#!/usr/bin/env bash

_koopa_os_string() {
    local id release_file str version
    id=''
    version=''
    if _koopa_is_macos
    then
        id='macos'
        version="$(_koopa_major_version "$(_koopa_macos_os_version)")"
    elif _koopa_is_linux
    then
        release_file='/etc/os-release'
        if [[ -r "$release_file" ]]
        then
            id="$( \
                awk -F= \
                    '$1=="ID" { print $2 ;}' \
                    "$release_file" \
                | tr -d '"' \
            )"
            version="$( \
                awk -F= \
                    '$1=="VERSION_ID" { print $2 ;}' \
                    "$release_file" \
                | tr -d '"' \
            )"
            if [[ -n "$version" ]]
            then
                version="$(_koopa_major_version "$version")"
            else
                version='rolling'
            fi
        else
            id='linux'
            version=''
        fi
    fi
    [[ -n "$id" ]] || return 1
    str="$id"
    if [[ -n "$version" ]]
    then
        str="${str}-${version}"
    fi
    _koopa_print "$str"
    return 0
}
