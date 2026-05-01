#!/usr/bin/env bash

_koopa_assert_is_dir() {
    # """
    # Assert that input is a directory.
    # @note Updated 2020-02-16.
    # """
    local arg
    _koopa_assert_has_args "$#"
    for arg in "$@"
    do
        if [[ ! -d "$arg" ]]
        then
            _koopa_stop "Not directory: '${arg}'."
        fi
    done
    return 0
}
