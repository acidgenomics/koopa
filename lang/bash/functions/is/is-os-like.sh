#!/usr/bin/env bash

_koopa_is_os_like() {
    local file id
    id="${1:?}"
    _koopa_is_os "$id" && return 0
    file='/etc/os-release'
    [[ -r "$file" ]] || return 1
    if grep 'ID=' "$file" | grep -q "$id"
    then
        return 0
    fi
    if grep 'ID_LIKE=' "$file" | grep -q "$id"
    then
        return 0
    fi
    return 1
}
