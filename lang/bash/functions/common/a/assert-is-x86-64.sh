#!/usr/bin/env bash

koopa_assert_is_x86_64() {
    # """
    # Assert that platform is x86 64-bit.
    # @note Updated 2024-01-03.
    # """
    koopa_assert_has_no_args "$#"
    if ! koopa_is_x86_64
    then
        koopa_stop 'Architecture is not x86 64-bit.'
    fi
    return 0
}
