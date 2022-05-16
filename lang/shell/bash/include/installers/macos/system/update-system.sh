#!/usr/bin/env bash

main() {
    # """
    # Update macOS system.
    # @note Updated 2022-01-27.
    # """
    local app
    koopa_assert_has_no_args "$#"
    declare -A app=(
        [softwareupdate]="$(koopa_macos_locate_softwareupdate)"
        [sudo]="$(koopa_locate_sudo)"
    )
    koopa_update_system
    koopa_alert "Updating macOS via '${app[softwareupdate]}'."
    koopa_alert_note 'Restart may be required.'
    "${app[sudo]}" "${app[softwareupdate]}" \
        --install \
        --recommended \
        --restart
    return 0
}
