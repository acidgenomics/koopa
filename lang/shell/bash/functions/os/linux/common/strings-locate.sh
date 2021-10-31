#!/usr/bin/env bash

# FIXME Need to prefix all of these with 'linux'.

koopa::locate_systemctl() { # {{{1
    # """
    # Locate Linux systemctl.
    # @note Updated 2021-10-31.
    # """
    koopa::assert_has_no_args "$#"
    koopa:::locate_app 'systemctl'  # FIXME Harden this
}

koopa::locate_update_alternatives() { # {{{1
    # """
    # Locate Linux update-alternatives.
    # @note Updated 2021-10-31.
    # """
    koopa::assert_has_no_args "$#"
    koopa:::locate_app 'update-alternatives'  # FIXME Harden this
}
