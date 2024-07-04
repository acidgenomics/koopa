#!/usr/bin/env bash

koopa_assert_is_admin() {
    # """
    # Assert that current user has admin permissions.
    # @note Updated 2024-06-27.
    # """
    koopa_assert_has_no_args "$#"
    if ! koopa_is_admin
    then
        koopa_stop \
            'Administrator account is required.' \
            "You may need to run 'sudo -v' to elevate current user."
    fi
    return 0
}
