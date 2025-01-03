#!/usr/bin/env bash

koopa_assert_is_not_amd64() {
    # """
    # Assert that platform is not amd64 / x86_64.
    # @note Updated 2025-01-03.
    # """
    koopa_assert_has_no_args "$#"
    if koopa_is_amd64
    then
        koopa_stop 'AMD 64-bit (amd64, x86_64) architecture is not supported.'
    fi
    return 0
}
