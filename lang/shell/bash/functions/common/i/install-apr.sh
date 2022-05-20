#!/usr/bin/env bash

koopa_install_apr() {
    koopa_install_app \
        --activate-opt='sqlite' \
        --name-fancy='Apache Portable Runtime (APR) library' \
        --name='apr' \
        "$@"
}
