#!/usr/bin/env bash

_koopa_macos_os_version() {
    local str
    str="$(/usr/bin/sw_vers -productVersion)"
    [[ -n "$str" ]] || return 1
    _koopa_print "$str"
    return 0
}
