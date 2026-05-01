#!/usr/bin/env bash

_koopa_assert_is_arm64() {
    # """
    # Assert that platform is ARM 64-bit.
    # @note Updated 2025-01-03.
    # """
    _koopa_assert_has_no_args "$#"
    if ! _koopa_is_arm64
    then
        _koopa_stop 'Architecture is not ARM 64-bit (arm64, aarch64).'
    fi
    return 0
}
