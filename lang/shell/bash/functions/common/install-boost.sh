#!/usr/bin/env bash

koopa_install_boost() { # {{{3
    koopa_install_app \
        --name-fancy='Boost' \
        --name='boost' \
        "$@"
}

koopa_uninstall_boost() { # {{{3
    koopa_uninstall_app \
        --name-fancy='Boost' \
        --name='boost' \
        "$@"
}
