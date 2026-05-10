#!/usr/bin/env bash

_koopa_assert_has_args_ge() {
    # """
    # Assert that greater-than-or-equal-to an expected number of arguments have
    # been passed.
    # @note Updated 2020-07-03.
    # """
    if [[ "$#" -ne 2 ]]
    then
        _koopa_stop '"_koopa_assert_has_args_ge" requires 2 args.'
    fi
    if [[ ! "${1:?}" -ge "${2:?}" ]]
    then
        _koopa_stop 'Invalid number of arguments.'
    fi
    return 0
}
