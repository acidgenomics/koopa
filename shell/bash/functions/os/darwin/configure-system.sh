#!/usr/bin/env bash

koopa::macos_configure_system() { # {{{1
    # """
    # Configure macOS system.
    # @note Updated 2020-11-20.
    # """
    koopa::assert_has_no_args "$#"
    koopa::assert_has_sudo
    koopa::h1 'Configuring macOS system.'
    koopa::enable_passwordless_sudo
    koopa::install_homebrew
    koopa::install_homebrew_packages
    koopa::install_conda
    koopa::install_python_packages
    koopa::macos_install_r_cran_gfortran
    koopa::install_r_packages
    koopa::macos_update_defaults
    koopa::success 'macOS configuration was successful.'
    return 0
}
