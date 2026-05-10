#!/usr/bin/env bash

_koopa_assert_is_readable() {
    # """
    # Assert that input is readable.
    # @note Updated 2020-02-16.
    # """
    local arg
    _koopa_assert_has_args "$#"
    for arg in "$@"
    do
        if [[ ! -r "$arg" ]]
        then
            _koopa_stop "Not readable: '${arg}'."
        fi
    done
    return 0
}
