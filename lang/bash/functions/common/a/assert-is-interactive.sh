#!/usr/bin/env bash

koopa_assert_is_interactive() {
    # """
    # Assert that current user has admin permissions.
    # @note Updated 2021-05-22.
    # """
    koopa_assert_has_no_args "$#"
    if ! koopa_is_interactive
    then
        koopa_stop 'Shell is not interactive.'
    fi
    return 0
}
