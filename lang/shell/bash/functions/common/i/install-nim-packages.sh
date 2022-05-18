#!/usr/bin/env bash

koopa_install_nim_packages() {
    koopa_install_app_packages \
        --link-in-bin='bin/markdown' \
        --name-fancy='Nim' \
        --name='nim' \
        "$@"
}
