#!/usr/bin/env zsh

_koopa_arch() {
    local string
    string="$(uname -m)"
    [[ -n "$string" ]] || return 1
    _koopa_print "$string"
    return 0
}
