#!/usr/bin/env zsh

_koopa_logged_in_user_count() {
    local string
    string="$(_koopa_logged_in_users | wc -l)"
    [[ -n "$string" ]] || return 1
    _koopa_print "$string"
    return 0
}
