#!/usr/bin/env bash

main() {
    # """
    # Uninstall RStudio Server.
    # @note Updated 2021-06-14.
    #
    # Consider deleting 'rstudio-server' user.
    # """
    koopa_debian_apt_remove 'rstudio-server'
    return 0
}
