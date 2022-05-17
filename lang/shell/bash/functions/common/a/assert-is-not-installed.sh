#!/usr/bin/env bash

koopa_assert_is_not_installed() {
    # """
    # Assert that programs are not installed.
    # @note Updated 2020-02-16.
    # """
    local arg where
    koopa_assert_has_args "$#"
    for arg in "$@"
    do
        if koopa_is_installed "$arg"
        then
            where="$(koopa_which_realpath "$arg")"
            koopa_stop "'${arg}' is already installed at '${where}'."
        fi
    done
    return 0
}
