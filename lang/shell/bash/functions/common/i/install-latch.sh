#!/usr/bin/env bash

koopa_install_latch() {
    koopa_install_app \
        --link-in-bin='latch' \
        --name='latch' \
        "$@"
}
