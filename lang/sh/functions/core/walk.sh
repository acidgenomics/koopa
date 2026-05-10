#!/bin/sh

_koopa_walk() {
    __kvar_walk="$(_koopa_bin_prefix)/walk"
    [ -x "$__kvar_walk" ] || return 1
    cd "$("$__kvar_walk" "$@")" || return 1
    unset -v __kvar_walk
    return 0
}
