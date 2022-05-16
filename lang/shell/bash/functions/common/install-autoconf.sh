#!/usr/bin/env bash

koopa_install_autoconf() { # {{{3
    koopa_install_app \
        --installer='gnu-app' \
        --name='autoconf' \
        "$@"
}

koopa_uninstall_autoconf() { # {{{3
    koopa_uninstall_app \
        --name='autoconf' \
        "$@"
}
