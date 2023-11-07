#!/usr/bin/env bash

koopa_assert_is_not_compressed_file() {
    # """
    # Assert that input is not a compressed file.
    # @note Updated 2023-11-07.
    # """
    local arg
    koopa_assert_has_args "$#"
    for arg in "$@"
    do
        if koopa_is_compressed_file "$arg"
        then
            koopa_stop "Compressed file: '${arg}'."
        fi
    done
    return 0
}
