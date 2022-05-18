#!/usr/bin/env bash

koopa_install_libidn() {
    koopa_install_app \
        --installer='gnu-app' \
        --name='libidn' \
        "$@"
}
