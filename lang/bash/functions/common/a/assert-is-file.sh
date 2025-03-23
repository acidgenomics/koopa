#!/usr/bin/env bash

koopa_assert_is_file() {
    # """
    # Assert that input is a file.
    # @note Updated 2020-02-16.
    # """
    local arg
    koopa_assert_has_args "$#"
    for arg in "$@"
    do
        if [[ ! -f "$arg" ]]
        then
            koopa_stop "Not file: '${arg}'."
        fi
    done
    return 0
}
