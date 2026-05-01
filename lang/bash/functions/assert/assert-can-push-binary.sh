#!/usr/bin/env bash

_koopa_assert_can_push_binary() {
    # """
    # Assert that current user has permission to push binary apps to S3.
    # @note Updated 2024-06-21.
    # """
    _koopa_assert_has_no_args "$#"
    if ! _koopa_can_push_binary
    then
        _koopa_stop 'System not configured to push binaries.'
    fi
    return 0
}
