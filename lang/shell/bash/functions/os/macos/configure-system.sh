#!/usr/bin/env bash

koopa_macos_configure_system() { # {{{1
    # """
    # Configure macOS system.
    # @note Updated 2020-11-23.
    # """
    koopa_assert_has_no_args "$#"
    koopa_assert_is_admin
    koopa_h1 'Configuring macOS system.'
    koopa_enable_passwordless_sudo
    koopa_install_homebrew
    koopa_install_homebrew_bundle
    koopa_install_conda
    koopa_macos_update_defaults
    koopa_alert_success 'macOS configuration was successful.'
    return 0
}
