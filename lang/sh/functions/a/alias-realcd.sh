#!/bin/sh

_koopa_alias_realcd() {
    # """
    # Change directory and automatically resolve realpath.
    # @note Updated 2025-04-27.
    #
    # Defaults to resolving current working directory.
    # """
    __kvar_dir="${1:-}"
    [ -z "$__kvar_dir" ] && __kvar_dir="$(pwd)"
    __kvar_dir="$(_koopa_realpath "$__kvar_dir")"
    cd "$__kvar_dir" || return 1
    unset -v __kvar_dir
    return 0
}
