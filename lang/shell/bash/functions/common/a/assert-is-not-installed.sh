#!/usr/bin/env bash

koopa_assert_is_not_installed() {
    # """
    # Assert that programs are not installed.
    # @note Updated 2023-03-12.
    # """
    local arg
    koopa_assert_has_args "$#"
    for arg in "$@"
    do
        if koopa_is_installed "$arg"
        then
            local where
            where="$(koopa_which_realpath "$arg")"
            koopa_stop "'${arg}' is already installed at '${where}'."
        fi
    done
    return 0
}
