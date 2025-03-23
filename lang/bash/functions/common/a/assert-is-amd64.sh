#!/usr/bin/env bash

koopa_assert_is_amd64() {
    # """
    # Assert that platform is AMD 64-bit (Intel x86 64-bit).
    # @note Updated 2024-01-03.
    # """
    koopa_assert_has_no_args "$#"
    if ! koopa_is_amd64
    then
        koopa_stop 'Architecture is not AMD 64-bit (amd64, x86_64).'
    fi
    return 0
}
