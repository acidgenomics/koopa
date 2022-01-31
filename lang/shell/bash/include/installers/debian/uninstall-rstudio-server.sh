#!/usr/bin/env bash

koopa:::debian_uninstall_rstudio_server() { # {{{1
    # """
    # Uninstall RStudio Server.
    # @note Updated 2021-06-14.
    # """
    koopa::assert_has_no_args "$#"
    koopa::assert_is_admin
    koopa::debian_apt_remove 'rstudio-server'
    return 0
}
