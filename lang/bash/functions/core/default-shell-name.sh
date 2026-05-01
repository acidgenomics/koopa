#!/usr/bin/env bash

_koopa_default_shell_name() {
    local str
    str="${SHELL:-sh}"
    str="$(basename "$str")"
    [[ -n "$str" ]] || return 1
    _koopa_print "$str"
    return 0
}
