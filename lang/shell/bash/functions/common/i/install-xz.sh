#!/usr/bin/env bash

koopa_install_xz() {
    koopa_install_app \
        --link-in-bin='bin/xz' \
        --name='xz' \
        "$@"
}
