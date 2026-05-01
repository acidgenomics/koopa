#!/usr/bin/env bash

_koopa_assert_is_compressed_file() {
    # """
    # Assert that input is a compressed file.
    # @note Updated 2023-11-07.
    # """
    local arg
    _koopa_assert_has_args "$#"
    for arg in "$@"
    do
        if ! _koopa_is_compressed_file "$arg"
        then
            _koopa_stop "Not a compressed file: '${arg}'."
        fi
    done
    return 0
}
