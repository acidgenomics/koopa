#!/usr/bin/env bash

koopa_assert_is_current_version() {
    # """
    # Assert that programs are installed (and current).
    # @note Updated 2020-02-16.
    # """
    local arg expected
    koopa_assert_has_args "$#"
    for arg in "$@"
    do
        if ! koopa_is_installed "$arg"
        then
            expected="$(koopa_variable "$arg")"
            koopa_stop "'${arg}' is not current; expecting '${expected}'."
        fi
    done
    return 0
}
