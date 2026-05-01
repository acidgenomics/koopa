#!/usr/bin/env bash

_koopa_assert_has_file_ext() {
    # """
    # Assert that input contains a file extension.
    # @note Updated 2020-02-16.
    # """
    local arg
    _koopa_assert_has_args "$#"
    for arg in "$@"
    do
        if ! _koopa_has_file_ext "$arg"
        then
            _koopa_stop "No file extension: '${arg}'."
        fi
    done
    return 0
}
