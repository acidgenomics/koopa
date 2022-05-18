#!/usr/bin/env bash

koopa_install_libtool() {
    koopa_install_app \
        --installer='gnu-app' \
        --name='libtool' \
        "$@"
}
