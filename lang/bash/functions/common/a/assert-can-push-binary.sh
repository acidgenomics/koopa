#!/usr/bin/env bash

koopa_assert_can_push_binary() {
    # """
    # Assert that current user has permission to push binary apps to S3.
    # @note Updated 2024-06-21.
    # """
    koopa_assert_has_no_args "$#"
    if ! koopa_can_push_binary
    then
        koopa_stop 'System not configured to push binaries.'
    fi
    return 0
}
