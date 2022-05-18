#!/usr/bin/env bash

koopa_install_rmate() {
    koopa_install_app \
        --link-in-bin='bin/rmate' \
        --name='rmate' \
        "$@"
}
