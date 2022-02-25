#!/usr/bin/env bash

debian_uninstall_shiny_server() { # {{{1
    # """
    # Uninstall Shiny Server.
    # @note Updated 2021-06-14.
    #
    # Consider deleting 'shiny' user.
    # """
    koopa_assert_has_no_args "$#"
    koopa_assert_is_admin
    koopa_debian_apt_remove 'shiny-server'
    return 0
}
