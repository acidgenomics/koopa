#!/usr/bin/env bash

koopa_install_lesspipe() {
    koopa_install_app \
        --link-in-bin='lesspipe.sh' \
        --name='lesspipe' \
        "$@"
}
