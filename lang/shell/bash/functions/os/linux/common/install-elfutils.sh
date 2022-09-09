#!/usr/bin/env bash

koopa_linux_install_elfutils() {
    koopa_install_app \
        --name='elfutils' \
        --platform='linux'
        "$@"
}
