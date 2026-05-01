#!/usr/bin/env bash

_koopa_assert_is_macos() {
    # """
    # Assert that operating system is macOS.
    # @note Updated 2023-03-12.
    # """
    _koopa_assert_has_no_args "$#"
    if ! _koopa_is_macos
    then
        _koopa_stop 'macOS is required.'
    fi
    return 0
}
