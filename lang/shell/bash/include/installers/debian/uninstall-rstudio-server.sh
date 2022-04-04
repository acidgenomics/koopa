#!/usr/bin/env bash

# FIXME Indicate that this is a binary install.

debian_uninstall_rstudio_server() { # {{{1
    # """
    # Uninstall RStudio Server.
    # @note Updated 2021-06-14.
    #
    # Consider deleting 'rstudio-server' user.
    # """
    koopa_assert_has_no_args "$#"
    koopa_assert_is_admin
    koopa_debian_apt_remove 'rstudio-server'
    return 0
}
