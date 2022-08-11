#!/usr/bin/env bash

# FIXME Break out to separate installer. Don't use '--activate-opt' here, as
# it can cause issues with binary package install.

koopa_install_stow() {
    # """
    # Install script uses 'Test::Output' Perl package.
    # """
    koopa_install_app \
        --activate-opt='perl' \
        --installer='gnu-app' \
        --link-in-bin='stow' \
        --name='stow' \
        "$@"
}
