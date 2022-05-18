#!/usr/bin/env bash

koopa_install_stow() {
    # """
    # Install script uses 'Test::Output' Perl package.
    # """
    koopa_install_app \
        --activate-opt='perl' \
        --installer='gnu-app' \
        --link-in-bin='bin/stow' \
        --name='stow' \
        "$@"
}
