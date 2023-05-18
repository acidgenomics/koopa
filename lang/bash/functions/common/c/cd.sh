#!/usr/bin/env bash

koopa_cd() {
    # """
    # Change directory quietly.
    # @note Updated 2021-05-26.
    # """
    local prefix
    koopa_assert_has_args_eq "$#" 1
    prefix="${1:?}"
    cd "$prefix" >/dev/null 2>&1 || return 1
    return 0
}
