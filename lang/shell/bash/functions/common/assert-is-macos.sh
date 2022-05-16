#!/usr/bin/env bash

koopa_assert_is_macos() {
    # """
    # Assert that operating system is macOS.
    # @note Updated 2020-11-13.
    # """
    if ! koopa_is_macos
    then
        koopa_stop 'macOS is required.'
    fi
    return 0
}
