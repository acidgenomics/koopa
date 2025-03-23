#!/usr/bin/env bash

main() {
    # """
    # Uninstall RStudio Server.
    # @note Updated 2021-06-16.
    # """
    koopa_fedora_dnf_remove 'rstudio-server'
    return 0
}
