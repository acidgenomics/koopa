#!/usr/bin/env bash

_koopa_assert_has_private_access() {
    # """
    # Assert that current user has access to our private S3 bucket.
    # @note Updated 2023-03-14.
    # """
    _koopa_assert_has_no_args "$#"
    if ! _koopa_has_private_access
    then
        _koopa_stop 'User does not have access to koopa private S3 bucket.'
    fi
    return 0
}
