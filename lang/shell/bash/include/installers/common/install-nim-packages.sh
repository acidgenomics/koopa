#!/usr/bin/env bash

koopa:::install_nim_packages() { # {{{1
    # """
    # Install Nim packages using nimble.
    # @note Updated 2022-02-10.
    #
    # @seealso
    # - https://github.com/nim-lang/nimble/issues/734
    # """
    local app i pkgs
    koopa::assert_has_no_args "$#"
    koopa::activate_nim
    declare -A app=(
        [nimble]="$(koopa::locate_nimble)"
    )
    pkgs=(
        'markdown'
    )
    for i in "${!pkgs[@]}"
    do
        local pkg pkg_lower version
        pkg="${pkgs[$i]}"
        pkg_lower="$(koopa::lowercase "$pkg")"
        version="$(koopa::variable "nim-${pkg_lower}")"
        pkgs[$i]="${pkg}@${version}"
    done
    "${app[nimble]}" install "${pkgs[@]}"
    return 0
}
