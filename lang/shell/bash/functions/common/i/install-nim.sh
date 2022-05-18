#!/usr/bin/env bash

koopa_install_nim() {
    koopa_install_app \
        --link-in-bin='bin/nim' \
        --name-fancy='Nim' \
        --name='nim' \
        "$@"
}
