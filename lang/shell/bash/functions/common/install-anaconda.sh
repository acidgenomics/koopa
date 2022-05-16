#!/usr/bin/env bash

koopa_install_anaconda() { # {{{3
    koopa_install_app \
        --name-fancy='Anaconda' \
        --name='anaconda' \
        "$@"
}

koopa_uninstall_anaconda() { # {{{3
    koopa_uninstall_app \
        --name-fancy='Anaconda' \
        --name='anaconda' \
        "$@"
}
