#!/usr/bin/env bash

koopa_linux_install_gcc() {
    koopa_install_app \
        --name='gcc' \
        --platform='linux' \
        "$@"
}
