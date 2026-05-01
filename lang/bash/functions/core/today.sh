#!/usr/bin/env bash

_koopa_today() {
    local str
    str="$(date '+%Y-%m-%d')"
    [[ -n "$str" ]] || return 1
    _koopa_print "$str"
    return 0
}
