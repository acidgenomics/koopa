#!/usr/bin/env bash

# FIXME Confirm that this works.

koopa:::debian_uninstall_rstudio_workbench() { # {{{1
    # """
    # Uninstall RStudio Workbench.
    # @note Updated 2021-06-14.
    # """
    koopa:::debian_uninstall_rstudio_server "$@"
    return 0
}
