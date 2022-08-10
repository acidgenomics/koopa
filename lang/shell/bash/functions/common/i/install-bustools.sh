#!/usr/bin/env bash

koopa_install_bustools() {
    koopa_install_app \
        --installer='conda-env' \
        --link-in-bin='bustools' \
        --name='bustools' \
        "$@"
}
