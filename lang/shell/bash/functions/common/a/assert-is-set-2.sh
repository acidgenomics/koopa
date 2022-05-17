#!/usr/bin/env bash

koopa_assert_is_set_2() {
    # """
    # Assert that variables are set (and not unbound).
    # @note Updated 2021-11-05.
    #
    # Intended to use inside of functions, where we can't be sure that
    # 'set -o nounset' mode is set, which otherwise catches unbound variables.
    #
    # How to return bash variable name:
    # - https://unix.stackexchange.com/questions/129084
    #
    # @examples
    # > koopa_assert_is_set_2 'PATH' 'MANPATH'
    # """
    local arg
    koopa_assert_has_args "$#"
    for arg in "$@"
    do
        if ! koopa_is_set "$arg"
        then
            koopa_stop "'${arg}' is unset."
        fi
    done
    return 0
}
