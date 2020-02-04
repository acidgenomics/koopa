#!/usr/bin/env bash

_koopa_assert_is_set() {
    # """
    # Assert that variables are set (and not unbound).
    # Updated 2020-02-04.
    #
    # Intended to use inside of functions, where we can't be sure that 'set -u'
    # mode is set, which otherwise catches unbound variables.
    #
    # How to return bash variable name:
    # - https://unix.stackexchange.com/questions/129084
    #
    # Example:
    # _koopa_assert_is_set PATH MANPATH xxx
    # """
    for arg
    do
        if [[ -z "${!arg:-}" ]]
        then
            _koopa_stop "'${arg}' is unset."
        fi
    done
    return 0
}
