#!/usr/bin/env bash

koopa_install_units() {
    koopa_install_app \
        --activate-opt='readline' \
        --installer='gnu-app' \
        --link-in-bin='bin/units' \
        --name='units' \
        "$@"
}
