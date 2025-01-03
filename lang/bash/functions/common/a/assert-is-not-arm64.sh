#!/usr/bin/env bash

koopa_assert_is_not_arm64() {
    # """
    # Assert that platform is not ARM 64-bit.
    # @note Updated 2025-01-03.
    # """
    koopa_assert_has_no_args "$#"
    if koopa_is_arm64
    then
        koopa_stop 'ARM 64-bit architecture (arm64, aarch64) is not supported.'
    fi
    return 0
}
