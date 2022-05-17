#!/usr/bin/env bash

koopa_assert_is_dir() {
    # """
    # Assert that input is a directory.
    # @note Updated 2020-02-16.
    # """
    local arg
    koopa_assert_has_args "$#"
    for arg in "$@"
    do
        if [[ ! -d "$arg" ]]
        then
            koopa_stop "Not directory: '${arg}'."
        fi
    done
    return 0
}
