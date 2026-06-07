#!/usr/bin/env zsh

_koopa_logged_in_users() {
    local string
    string="$( \
        who -q \
        | awk 'NR > 1 { print prev } { prev = $0 }' \
        | tr ' ' '\n' \
        | sort \
        | uniq \
    )"
    [[ -n "$string" ]] || return 1
    _koopa_print "$string"
    return 0
}
