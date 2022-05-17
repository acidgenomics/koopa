#!/usr/bin/env bash

koopa_assert_is_symlink() {
    # """
    # Assert that input is a symbolic link.
    # @note Updated 2020-02-16.
    # """
    local arg
    koopa_assert_has_args "$#"
    for arg in "$@"
    do
        if [[ ! -L "$arg" ]]
        then
            koopa_stop "Not symlink: '${arg}'."
        fi
    done
    return 0
}
