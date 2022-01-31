#!/usr/bin/env bash

koopa:::debian_uninstall_shiny_server() { # {{{1
    # """
    # Uninstall Shiny Server.
    # @note Updated 2021-06-14.
    #
    # Consider deleting 'shiny' user.
    # """
    koopa::assert_has_no_args "$#"
    koopa::assert_is_admin
    koopa::debian_apt_remove 'shiny-server'
    return 0
}
