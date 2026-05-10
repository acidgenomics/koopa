#!/usr/bin/env bash

_koopa_assert_has_args() {
    # """
    # Assert that non-zero arguments have been passed.
    # @note Updated 2022-02-15.
    # Does not check for empty strings.
    # """
    if [[ "$#" -ne 1 ]]
    then
        _koopa_stop \
            '"_koopa_assert_has_args" requires 1 arg.' \
            'Pass "$#" not "$@" to this function.'
    fi
    if [[ "${1:?}" -eq 0 ]]
    then
        _koopa_stop 'Required arguments missing.'
    fi
    return 0
}
