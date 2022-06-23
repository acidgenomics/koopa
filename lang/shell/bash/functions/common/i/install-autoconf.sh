#!/usr/bin/env bash

koopa_install_autoconf() {
    koopa_install_app \
        --activate-opt='m4' \
        --installer='gnu-app' \
        --name='autoconf' \
        "$@"
}
