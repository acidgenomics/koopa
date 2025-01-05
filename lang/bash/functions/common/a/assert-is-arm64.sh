#!/usr/bin/env bash

koopa_assert_is_arm64() {
    # """
    # Assert that platform is ARM 64-bit.
    # @note Updated 2025-01-03.
    # """
    koopa_assert_has_no_args "$#"
    if ! koopa_is_arm64
    then
        koopa_stop 'Architecture is not ARM 64-bit (arm64, aarch64).'
    fi
    return 0
}
