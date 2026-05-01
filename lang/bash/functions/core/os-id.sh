#!/usr/bin/env bash

_koopa_os_id() {
    local str
    str="$(_koopa_os_string | cut -d '-' -f 1)"
    [[ -n "$str" ]] || return 1
    _koopa_print "$str"
    return 0
}
