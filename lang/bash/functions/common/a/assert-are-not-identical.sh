#!/usr/bin/env bash

koopa_assert_are_not_identical() {
    # """
    # Assert that two strings are not identical.
    # @note Updated 2020-07-03.
    # """
    koopa_assert_has_args_eq "$#" 2
    if [[ "${1:?}" == "${2:?}" ]]
    then
        koopa_stop "'${1}' is identical to '${2}'."
    fi
    return 0
}
