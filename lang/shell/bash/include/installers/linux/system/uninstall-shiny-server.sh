#!/usr/bin/env bash

# FIXME Need to add support for Fedora.

main() { # {{{1
    # """
    # Uninstall Shiny Server.
    # @note Updated 2022-04-07.
    #
    # Consider deleting 'shiny' user.
    # """
    koopa_assert_has_no_args "$#"
    # FIXME Need to add support for Fedora here.
    # FIXME Error for unsupported distro.
    koopa_debian_apt_remove 'shiny-server'
    return 0
}
