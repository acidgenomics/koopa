#!/usr/bin/env bash

koopa:::fedora_uninstall_rstudio_server() { # {{{1
    # """
    # Uninstall RStudio Server.
    # @note Updated 2021-06-16.
    # """
    koopa::assert_has_no_args "$#"
    koopa::assert_is_admin
    koopa::fedora_dnf_remove 'rstudio-server'
    return 0
}
