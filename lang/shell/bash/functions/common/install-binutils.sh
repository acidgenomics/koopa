#!/usr/bin/env bash

koopa_install_binutils() { # {{{3
    koopa_install_app \
        --installer='gnu-app' \
        --name='binutils' \
        "$@"
}

koopa_uninstall_binutils() { # {{{3
    koopa_uninstall_app \
        --name='binutils' \
        "$@"
}
