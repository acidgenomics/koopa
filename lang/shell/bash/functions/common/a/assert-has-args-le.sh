#!/usr/bin/env bash

koopa_assert_has_args_le() {
    # """
    # Assert that less-than-or-equal-to an expected number of arguments have
    # been passed.
    # @note Updated 2020-07-03.
    # """
    if [[ "$#" -ne 2 ]]
    then
        koopa_stop '"koopa_assert_has_args_le" requires 2 args.'
    fi
    if [[ ! "${1:?}" -le "${2:?}" ]]
    then
        koopa_stop 'Invalid number of arguments.'
    fi
    return 0
}
