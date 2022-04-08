#!/usr/bin/env bash

main() { # {{{1
    # """
    # Uninstall RStudio Server.
    # @note Updated 2021-06-16.
    # """
    koopa_assert_has_no_args "$#"
    koopa_fedora_dnf_remove 'rstudio-server'
    return 0
}
