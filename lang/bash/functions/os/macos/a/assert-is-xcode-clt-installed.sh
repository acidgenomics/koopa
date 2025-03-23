#!/usr/bin/env bash

koopa_macos_assert_is_xcode_clt_installed() {
    # """
    # Assert that Xcode Command Line Tools (CLT) are installed.
    # @note Updated 2023-05-20.
    # """
    koopa_assert_has_no_args "$#"
    if ! koopa_macos_is_xcode_clt_installed
    then
        koopa_stop \
            'Xcode Command Line Tools (CLT) are not installed.' \
            "Resolve with 'koopa install system xcode-clt'."
    fi
    return 0
}
