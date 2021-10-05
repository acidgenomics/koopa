#!/usr/bin/env bash

koopa::install_nim_packages() { # {{{1
    koopa:::install_app_packages \
        --name-fancy='Nim' \
        --name='nim' \
        "$@"
}

koopa:::install_nim_packages() { # {{{1
    # """
    # Install Nim packages using nimble.
    # @note Updated 2021-10-05.
    # @seealso
    # - https://github.com/nim-lang/nimble/issues/734
    # """
    local nimble pkg pkg_lower pkgs version
    koopa::assert_has_no_args "$#"
    koopa::configure_nim
    koopa::activate_nim
    nimble="$(koopa::locate_nimble)"
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
    "$nimble" install "${pkgs[@]}"
    return 0
}

koopa::uninstall_nim_packages() { # {{{1
    # """
    # Uninstall Nim packages.
    # @note Updated 2021-10-05.
    # """
    koopa:::uninstall_app \
        --name='nim-packages' \
        --name-fancy='Nim packages' \
        --no-link \
        "$@"
    }

koopa::update_nim_packages() { # {{{1
    # """
    # Update Nim packages.
    # @note Updated 2021-10-05.
    # """
    koopa::install_nim_packages "$@"
}
