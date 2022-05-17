#!/usr/bin/env bash

koopa_install_automake() {
    koopa_install_app \
        --activate-opt='autoconf' \
        --installer='gnu-app' \
        --name='automake' \
        "$@"
}
