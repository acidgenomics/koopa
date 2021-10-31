#!/usr/bin/env bash

koopa::macos_update_system() { # {{{1
    # """
    # Update macOS system.
    # @note Updated 2021-10-31.
    # """
    local app
    koopa::assert_has_no_args "$#"
    koopa::assert_is_admin
    declare -A app=(
        [mas]="$(koopa::locate_mas)"
        [softwareupdate]="$(koopa::locate_softwareupdate)"
        [sudo]="$(koopa::locate_sudo)"
    )
    koopa::alert "Updating App Store apps via '${app[mas]}'."
    "${app[mas]}" upgrade
    koopa::alert "Updating macOS via '${app[softwareupdate]}'."
    koopa::alert_note 'Restart may be required.'
    "${app[sudo]}" "${app[softwareupdate]}" \
        --install \
        --recommended \
        --restart
    return 0
}
