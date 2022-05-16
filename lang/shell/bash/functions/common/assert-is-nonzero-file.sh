#!/usr/bin/env bash

koopa_assert_is_nonzero_file() {
    # """
    # Assert that input is a non-zero file.
    # @note Updated 2020-03-06.
    # """
    local arg
    koopa_assert_has_args "$#"
    for arg in "$@"
    do
        if [[ ! -s "$arg" ]]
        then
            koopa_stop "Not non-zero file: '${arg}'."
        fi
    done
    return 0
}
