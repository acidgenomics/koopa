#!/usr/bin/env bash

# FIXME Need to link into koopa bin.

main() {
    # """
    # Uninstall Shiny Server.
    # @note Updated 2022-04-08.
    #
    # Consider deleting 'shiny' user.
    # """
    koopa_assert_has_no_args "$#"
    koopa_fedora_dnf_remove 'shiny-server'
    return 0
}
