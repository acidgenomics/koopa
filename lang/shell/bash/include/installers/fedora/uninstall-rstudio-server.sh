#!/usr/bin/env bash

koopa:::fedora_uninstall_rstudio_server() { # {{{1
    # """
    # Uninstall RStudio Server.
    # @note Updated 2021-06-16.
    # """
    koopa::fedora_dnf_remove 'rstudio-server'
}
