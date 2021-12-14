#!/usr/bin/env bash

koopa:::install_nim_packages() { # {{{1
    # """
    # Install Nim packages using nimble.
    # @note Updated 2021-12-14.
    # @seealso
    # - https://github.com/nim-lang/nimble/issues/734
    # """
    local app pkg pkg_lower pkgs version
    koopa::assert_has_no_args "$#"
    declare -A app=(
        [nimble]="$(koopa::locate_nimble)"
    )
    koopa::configure_nim
    koopa::activate_nim
    pkgs=("$@")
    if [[ "${#pkgs[@]}" -eq 0 ]]
    then
        pkgs=(
            'markdown'
        )
        for i in "${!pkgs[@]}"
        do
            pkg="${pkgs[$i]}"
            pkg_lower="$(koopa::lowercase "$pkg")"
            version="$(koopa::variable "nim-${pkg_lower}")"
            pkgs[$i]="${pkg}@${version}"
        done
    fi
    "${app[nimble]}" install "${pkgs[@]}"
    return 0
}
