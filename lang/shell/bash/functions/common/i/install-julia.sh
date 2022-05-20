#!/usr/bin/env bash

koopa_install_julia() {
    koopa_install_app \
        --link-in-bin='bin/julia' \
        --name-fancy='Julia' \
        --name='julia' \
        "$@"
}
