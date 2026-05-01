#!/usr/bin/env bash

_koopa_assert_is_function() {
    # """
    # Assert that variable is a function.
    # @note Updated 2020-02-16.
    # """
    local arg
    _koopa_assert_has_args "$#"
    for arg in "$@"
    do
        if ! _koopa_is_function "$arg"
        then
            _koopa_stop "Not function: '${arg}'."
        fi
    done
    return 0
}
