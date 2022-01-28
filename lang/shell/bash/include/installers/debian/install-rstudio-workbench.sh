#!/usr/bin/env bash

koopa:::debian_install_rstudio_workbench() { # {{{1
    # """
    # Install RStudio Workbench.
    # @note Updated 2021-06-11.
    # """
    koopa:::debian_install_rstudio_server --workbench "$@"
    return 0
}
