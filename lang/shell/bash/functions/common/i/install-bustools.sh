#!/usr/bin/env bash

koopa_install_bustools() {
    koopa_install_app \
        --link-in-bin='bustools' \
        --name='bustools' \
        "$@"
}
