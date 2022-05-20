#!/usr/bin/env bash

koopa_linux_install_julia_binary() {
    koopa_install_app \
        --installer="julia-binary" \
        --link-in-bin='bin/julia' \
        --name-fancy='Julia' \
        --name='julia' \
        --platform='linux' \
        "$@"
}
