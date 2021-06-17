#!/usr/bin/env bash

koopa::macos_update_system() { # {{{1
    # """
    # Update macOS system.
    # @note Updated 2020-11-12.
    # """
    koopa::assert_has_no_args "$#"
    if koopa::is_installed 'mas'
    then
        koopa::h1 "Updating App Store apps via 'mas'."
        mas upgrade
    fi
    koopa::h1 "Updating macOS via 'softwareupdate'."
    koopa::alert_note 'Restart may be required.'
    sudo softwareupdate --install --recommended --restart
    return 0
}
