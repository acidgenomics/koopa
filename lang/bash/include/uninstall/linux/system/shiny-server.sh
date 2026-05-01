#!/usr/bin/env bash

main() {
    # """
    # Uninstall Shiny Server.
    # @note Updated 2023-05-21.
    #
    # Consider deleting 'shiny' user.
    # """
    if _koopa_is_debian_like
    then
        _koopa_debian_apt_remove 'shiny-server'
    elif _koopa_is_fedora_like
    then
        _koopa_fedora_dnf_remove 'shiny-server'
    else
        _koopa_stop 'Unsupported Linux system.'
    fi
    return 0
}
