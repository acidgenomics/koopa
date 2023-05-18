#!/usr/bin/env bash

koopa_assert_is_not_aarch64() {
    # """
    # Assert that platform is not aarch64 / arm64.
    # @note Updated 2022-11-16.
    # """
    koopa_assert_has_no_args "$#"
    if koopa_is_aarch64
    then
        koopa_stop 'ARM (aarch64) is not supported.'
    fi
    return 0
}
