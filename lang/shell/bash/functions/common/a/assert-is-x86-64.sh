#!/usr/bin/env bash

koopa_assert_is_x86_64() {
    # """
    # Assert that platform is Intel x86 64-bit.
    # @note Updated 2021-11-02.
    # """
    koopa_assert_has_no_args "$#"
    if ! koopa_is_x86_64
    then
        koopa_stop 'Architecture is not x86_64 (Intel x86 64-bit).'
    fi
    return 0
}
