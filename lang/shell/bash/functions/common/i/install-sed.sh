#!/usr/bin/env bash

koopa_install_sed() {
    koopa_install_app \
        --installer='gnu-app' \
        --link-in-bin='bin/sed' \
        --name='sed' \
        "$@"
}
