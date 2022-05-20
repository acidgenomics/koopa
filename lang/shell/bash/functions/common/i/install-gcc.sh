#!/usr/bin/env bash

koopa_install_gcc() {
    koopa_install_app \
        --name-fancy='GCC' \
        --name='gcc' \
        "$@"
}
