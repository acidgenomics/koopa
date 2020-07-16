#!/usr/bin/env bash

koopa::macos_install_pytaglib() {
    # """
    # Install pytaglib.
    # @note Updated 2020-07-16.
    # """
    koopa::assert_has_no_args "$#"
    koopa::assert_is_installed brew pip
    brew install taglib &>/dev/null
    pip install \
        --global-option='build_ext' \
        --global-option='-I/usr/local/include/' \
        --global-option='-L/usr/local/lib' \
        pytaglib
    return 0
}
