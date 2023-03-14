#!/usr/bin/env bash

koopa_assert_has_private_access() {
    # """
    # Assert that current user has access to our private S3 bucket.
    # @note Updated 2023-03-14.
    # """
    koopa_assert_has_no_args "$#"
    if ! koopa_has_private_access
    then
        koopa_stop 'User does not have access to koopa private S3 bucket.'
    fi
    return 0
}
