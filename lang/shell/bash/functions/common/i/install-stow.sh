#!/usr/bin/env bash

koopa_install_stow() {
    koopa_install_app \
        --link-in-bin='stow' \
        --name='stow' \
        "$@"
}
