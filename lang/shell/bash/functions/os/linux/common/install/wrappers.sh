#!/usr/bin/env bash

# FIXME Need to improve consolidation of wrappers here.

koopa::linux_install_aspera_connect() { # {{{1
    koopa:::install_app \
        --name='aspera-connect' \
        --name-fancy='Aspera Connect' \
        --no-link \
        --platform='linux' \
        "$@"
}

koopa::linux_uninstall_aspera_connect() { # {{{1
    # """
    # Uninstall Aspera Connect.
    # @note Updated 2021-06-11.
    # """
    koopa:::uninstall_app \
        --name='aspera-connect' \
        --name-fancy='Aspera Connect' \
        --no-link \
        "$@"
}
