#!/usr/bin/env bash

koopa::macos_open_app() {
    # """
    # Open a macOS GUI application.
    # @note Updated 2020-07-16.
    # """
    local name
    koopa::assert_has_args_eq "$#" 1
    name="${1:?}"
    open -a "${name}.app"
    return 0
}

