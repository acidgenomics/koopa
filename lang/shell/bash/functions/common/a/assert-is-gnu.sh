#!/usr/bin/env bash

koopa_assert_is_gnu() {
    # """
    # Assert that GNU version of a program is installed.
    # @note Updated 2021-05-20.
    # """
    local arg
    koopa_assert_has_args "$#"
    for arg in "$@"
    do
        if ! koopa_is_gnu "$arg"
        then
            koopa_stop "GNU ${arg} is not installed."
        fi
    done
    return 0
}
