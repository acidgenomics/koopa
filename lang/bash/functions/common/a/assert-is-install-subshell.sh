#!/usr/bin/env bash

koopa_assert_is_install_subshell() {
    # """
    # Assert that call is inside our isolated app installer subshell.
    # @note Updated 2023-08-29.
    # """
    koopa_assert_has_no_args "$#"
    if ! koopa_is_install_subshell
    then
        koopa_stop 'Unsupported command.'
    fi
    return 0
}
