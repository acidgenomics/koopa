#!/usr/bin/env bash

_koopa_assert_are_identical() {
    # """
    # Assert that two strings are identical.
    # @note Updated 2020-07-07.
    # """
    _koopa_assert_has_args_eq "$#" 2
    if [[ "${1:?}" != "${2:?}" ]]
    then
        _koopa_stop "'${1}' is not identical to '${2}'."
    fi
    return 0
}
