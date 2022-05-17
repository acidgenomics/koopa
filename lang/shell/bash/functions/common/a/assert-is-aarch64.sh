#!/usr/bin/env bash

koopa_assert_is_aarch64() {
    # """
    # Assert that platform is ARM 64-bit.
    # @note Updated 2021-11-02.
    # """
    koopa_assert_has_no_args "$#"
    if ! koopa_is_aarch64
    then
        koopa_stop 'Architecture is not aarch64 (ARM 64-bit).'
    fi
    return 0
}
