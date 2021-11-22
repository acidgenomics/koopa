#!/usr/bin/env bash

koopa::macos_open_app() { # {{{1
    # """
    # Open a macOS GUI application.
    # @note Updated 2021-11-16.
    # """
    local name
    koopa::assert_has_args_eq "$#" 1
    declare -A app=(
        [open]="$(koopa::macos_locate_open)"
    )
    name="${1:?}"
    "${app[open]}" -a "${name}.app"
    return 0
}

koopa::macos_sudo_open_app() { # {{{1
    # """
    # Open a macOS GUI application with admin permissions.
    # @note Updated 2021-11-16.
    # """
    local app
    koopa::assert_has_args_eq "$#" 1
    declare -A app=(
        [open]="$(koopa::macos_locate_open)"
        [sudo]="$(koopa::locate_sudo)"
    )
    name="${1:?}"
    "${app[sudo]}" "${app[open]}" -a "${name}.app"
    return 0
}
