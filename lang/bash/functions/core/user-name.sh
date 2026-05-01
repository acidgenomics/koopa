#!/usr/bin/env bash

_koopa_user_name() {
    local str
    str="$(id -un)"
    [[ -n "$str" ]] || return 1
    _koopa_print "$str"
    return 0
}
