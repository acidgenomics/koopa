#!/usr/bin/env bash

_koopa_group_id() {
    local str
    str="$(id -g)"
    [[ -n "$str" ]] || return 1
    _koopa_print "$str"
    return 0
}
