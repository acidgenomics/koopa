#!/usr/bin/env bash

main() {
    # """
    # Uninstall pihole.
    # @note Updated 2023-05-22.
    #
    # @seealso
    # - https://docs.pi-hole.net/main/uninstall/
    # """
    local -A app
    app['pihole']="$(koopa_linux_locate_pihole --allow-missing)"
    if [[ ! -x "${app['pihole']}" ]]
    then
        koopa_alert_note "'pihole' is not installed."
        return 0
    fi
    "${app['pihole']}" uninstall
    return 0
}
