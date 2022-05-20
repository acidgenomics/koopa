#!/usr/bin/env bash

koopa_install_groff() {
    koopa_install_app \
        --installer='gnu-app' \
        --link-in-bin='bin/groff' \
        --name='groff' \
        "$@"
}
