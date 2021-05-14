#!/usr/bin/env bash

koopa::macos_configure_system() { # {{{1
    # """
    # Configure macOS system.
    # @note Updated 2020-11-23.
    # """
    koopa::assert_has_no_args "$#"
    koopa::assert_is_admin
    koopa::h1 'Configuring macOS system.'
    koopa::enable_passwordless_sudo
    koopa::install_homebrew
    koopa::install_homebrew_packages
    koopa::install_conda
    koopa::macos_update_defaults
    koopa::alert_success 'macOS configuration was successful.'
    return 0
}
