#!/usr/bin/env bash

_koopa_which() {
    # """
    # Locate which program.
    # @note Updated 2021-05-26.
    #
    # Example:
    # _koopa_which bash
    # """
    local cmd
    _koopa_assert_has_args "$#"
    for cmd in "$@"
    do
        if _koopa_is_alias "$cmd"
        then
            unalias "$cmd"
        elif _koopa_is_function "$cmd"
        then
            unset -f "$cmd"
        fi
        cmd="$(command -v "$cmd")"
        [[ -x "$cmd" ]] || return 1
        _koopa_print "$cmd"
    done
    return 0
}
