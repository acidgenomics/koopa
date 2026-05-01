#!/usr/bin/env bash

_koopa_assert_is_amd64() {
    # """
    # Assert that platform is AMD 64-bit (Intel x86 64-bit).
    # @note Updated 2024-01-03.
    # """
    _koopa_assert_has_no_args "$#"
    if ! _koopa_is_amd64
    then
        _koopa_stop 'Architecture is not AMD 64-bit (amd64, x86_64).'
    fi
    return 0
}
