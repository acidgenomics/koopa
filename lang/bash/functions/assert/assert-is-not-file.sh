#!/usr/bin/env bash

_koopa_assert_is_not_file() {
    # """
    # Assert that input is not a file.
    # @note Updated 2020-02-16.
    # """
    local arg
    _koopa_assert_has_args "$#"
    for arg in "$@"
    do
        if [[ -f "$arg" ]]
        then
            _koopa_stop "File exists: '${arg}'."
        fi
    done
    return 0
}
