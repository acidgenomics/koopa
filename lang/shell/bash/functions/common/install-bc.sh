#!/usr/bin/env bash

koopa_install_bc() {
    koopa_install_app \
        --installer='gnu-app' \
        --link-in-bin='bin/bc' \
        --name='bc' \
        "$@"
}
