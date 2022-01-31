#!/usr/bin/env bash

koopa:::fedora_uninstall_rstudio_workbench() { # {{{1
    # """
    # Uninstall RStudio Workbench.
    # @note Updated 2022-01-31.
    # """
    koopa:::fedora_uninstall_rstudio_server "$@"
}
