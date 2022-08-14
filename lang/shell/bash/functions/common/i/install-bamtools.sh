#!/usr/bin/env bash

koopa_install_bamtools() {
    koopa_install_app \
        --link-in-bin='bamtools' \
        --name='bamtools' \
        "$@"
}
