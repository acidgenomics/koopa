#!/usr/bin/env bash

koopa_install_gzip() {
    koopa_install_app \
        --installer='gnu-app' \
        --name='gzip' \
        "$@"
}
