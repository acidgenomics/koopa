#!/usr/bin/env bash

main() {
    # """
    # Uninstall Shiny Server.
    # @note Updated 2022-04-08.
    #
    # Consider deleting 'shiny' user.
    # """
    koopa_debian_apt_remove 'shiny-server'
    return 0
}
