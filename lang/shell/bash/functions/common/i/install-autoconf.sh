#!/usr/bin/env bash

koopa_install_autoconf() {
    koopa_install_app \
        --installer='gnu-app' \
        --name='autoconf' \
        "$@"
}
