#!/usr/bin/env bash

koopa_install_automake() { # {{{3
    koopa_install_app \
        --activate-opt='autoconf' \
        --installer='gnu-app' \
        --name='automake' \
        "$@"
}

koopa_uninstall_automake() { # {{{3
    koopa_uninstall_app \
        --name='automake' \
        "$@"
}
