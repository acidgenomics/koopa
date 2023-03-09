#!/usr/bin/env bash

__koopa_msg() {
    # """
    # Standard message generator.
    # @note Updated 2022-02-25.
    # """
    local c1 c2 nc prefix str
    c1="$(__koopa_ansi_escape "${1:?}")"
    c2="$(__koopa_ansi_escape "${2:?}")"
    nc="$(__koopa_ansi_escape 'nocolor')"
    prefix="${3:?}"
    shift 3
    for str in "$@"
    do
        koopa_print "${c1}${prefix}${nc} ${c2}${str}${nc}"
    done
    return 0
}
