#!/usr/bin/env bash

koopa_which() {
    # """
    # Locate which program.
    # @note Updated 2021-05-26.
    #
    # Example:
    # koopa_which bash
    # """
    local cmd
    koopa_assert_has_args "$#"
    for cmd in "$@"
    do
        if koopa_is_alias "$cmd"
        then
            unalias "$cmd"
        elif koopa_is_function "$cmd"
        then
            unset -f "$cmd"
        fi
        cmd="$(command -v "$cmd")"
        [[ -x "$cmd" ]] || return 1
        koopa_print "$cmd"
    done
    return 0
}
