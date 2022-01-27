#!/usr/bin/env bash

koopa:::debian_uninstall_shiny_server() { # {{{1
    # """
    # Uninstall Shiny Server.
    # @note Updated 2021-06-14.
    # """
    koopa::debian_apt_remove 'shiny-server'
}
