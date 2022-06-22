#!/usr/bin/env bash

koopa_install_libtool() {
    koopa_install_app \
        --installer='gnu-app' \
        --link-in-bin='bin/libtool' \
        --link-in-bin='bin/libtoolize' \
        --name='libtool' \
        "$@"
}
