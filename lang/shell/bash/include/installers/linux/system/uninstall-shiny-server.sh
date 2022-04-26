#!/usr/bin/env bash

main() { # {{{1
    # """
    # Uninstall Shiny Server.
    # @note Updated 2022-04-08.
    #
    # Consider deleting 'shiny' user.
    # """
    koopa_assert_has_no_args "$#"
    koopa_debian_apt_remove 'shiny-server'
    return 0
}
