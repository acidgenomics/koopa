#!/usr/bin/env bash

_koopa_group_name() {
    local str
    str="$(id -gn)"
    [[ -n "$str" ]] || return 1
    _koopa_print "$str"
    return 0
}
