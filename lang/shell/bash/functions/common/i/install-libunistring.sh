#!/usr/bin/env bash

koopa_install_libunistring() {
    koopa_install_app \
        --installer='gnu-app' \
        --name='libunistring' \
        "$@"
}
