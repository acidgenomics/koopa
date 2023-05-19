#!/usr/bin/env bash

koopa_assert_are_identical() {
    # """
    # Assert that two strings are identical.
    # @note Updated 2020-07-07.
    # """
    koopa_assert_has_args_eq "$#" 2
    if [[ "${1:?}" != "${2:?}" ]]
    then
        koopa_stop "'${1}' is not identical to '${2}'."
    fi
    return 0
}
