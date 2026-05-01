#!/usr/bin/env zsh

_koopa_user_id() {
    local string
    string="$(id -u)"
    [[ -n "$string" ]] || return 1
    _koopa_print "$string"
    return 0
}
