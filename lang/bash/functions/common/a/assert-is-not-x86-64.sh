#!/usr/bin/env bash

koopa_assert_is_not_x86_64() {
    # """
    # Assert that platform is not amd64 / x86_64.
    # @note Updated 2024-01-03.
    # """
    koopa_assert_has_no_args "$#"
    if koopa_is_x86_64
    then
        koopa_stop 'x86 64-bit is not supported.'
    fi
    return 0
}
