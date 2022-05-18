#!/usr/bin/env bash

koopa_install_parallel() {
    koopa_install_app \
        --installer='gnu-app' \
        --link-in-bin='bin/parallel' \
        --name='parallel' \
        "$@"
}
