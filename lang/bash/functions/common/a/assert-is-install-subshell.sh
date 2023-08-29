#!/usr/bin/env bash

koopa_assert_is_install_subshell() {
    # """
    # Assert that call is inside our isolated app installer subshell.
    # @note Updated 2023-08-29.
    # """
    koopa_assert_has_no_args "$#"
    if [[ -z "${KOOPA_INSTALL_NAME:-}" ]]
    then
        koopa_stop 'Unsupported command.'
    fi
    return 0
}
