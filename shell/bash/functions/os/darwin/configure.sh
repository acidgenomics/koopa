#!/usr/bin/env bash

koopa::configure_macos() { # {{{1
    # """
    # Configure macOS.
    # @note Updated 2020-07-18.
    # """
    koopa::assert_has_no_args "$#"
    koopa::h1 'Configuring macOS system.'
    koopa::enable_passwordless_sudo
    koopa::macos_install_homebrew
    koopa::macos_install_homebrew_packages
    koopa::install_conda
    koopa::macos_install_r_cran_gfortran
    koopa::install_python_packages
    install-r-packages
    koopa::update_macos_defaults
    koopa::success 'macOS configuration was successful.'
    return 0
}
