#!/usr/bin/env bash

koopa_assert_can_install_binary() {
    # """
    # Assert that current user has permission to install binary shared apps.
    # @note Updated 2023-10-13.
    # """
    koopa_assert_has_no_args "$#"
    if ! koopa_can_install_binary
    then
        koopa_stop 'No binary file access.'
    fi
    return 0
}
