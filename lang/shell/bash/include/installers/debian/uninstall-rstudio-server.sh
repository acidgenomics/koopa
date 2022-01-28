#!/usr/bin/env bash

koopa:::debian_uninstall_rstudio_server() { # {{{1
    # """
    # Uninstall RStudio Server.
    # @note Updated 2021-06-14.
    # """
    koopa::debian_apt_remove 'rstudio-server'
    return 0
}
