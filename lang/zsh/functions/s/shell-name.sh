#!/usr/bin/env zsh

_koopa_shell_name() {
    local shell
    shell="$(_koopa_locate_shell)"
    shell="$(basename "$shell")"
    [[ -n "$shell" ]] || return 1
    _koopa_print "$shell"
    return 0
}
