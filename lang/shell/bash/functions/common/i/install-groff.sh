#!/usr/bin/env bash

koopa_install_groff() {
    koopa_install_app \
        --activate-opt='texinfo' \
        --installer='gnu-app' \
        --link-in-bin='groff' \
        --name='groff' \
        "$@"
}
