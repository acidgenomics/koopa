#!/usr/bin/env bash

koopa_assert_has_no_args() {
    # """
    # Assert that the user has not passed any arguments to a script.
    # @note Updated 2022-02-15.
    # """
    if [[ "$#" -ne 1 ]]
    then
        koopa_stop \
            '"koopa_assert_has_no_args" requires 1 arg.' \
            'Pass "$#" not "$@" to this function.'
    fi
    if [[ "${1:?}" -ne 0 ]]
    then
        koopa_stop "Arguments are not allowed (${1} detected)."
    fi
    return 0
}
