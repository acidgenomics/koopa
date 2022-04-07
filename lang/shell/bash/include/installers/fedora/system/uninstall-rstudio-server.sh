#!/usr/bin/env bash

# FIXME Indicate that this is a binary install.

main() { # {{{1
    # """
    # Uninstall RStudio Server.
    # @note Updated 2021-06-16.
    # """
    koopa_assert_has_no_args "$#"
    koopa_assert_is_admin
    koopa_fedora_dnf_remove 'rstudio-server'
    return 0
}
