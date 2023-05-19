#!/usr/bin/env bash

koopa_assert_is_macos() {
    # """
    # Assert that operating system is macOS.
    # @note Updated 2023-03-12.
    # """
    koopa_assert_has_no_args "$#"
    if ! koopa_is_macos
    then
        koopa_stop 'macOS is required.'
    fi
    return 0
}
