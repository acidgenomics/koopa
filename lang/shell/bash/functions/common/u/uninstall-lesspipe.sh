#!/usr/bin/env bash

koopa_uninstall_lesspipe() {
    koopa_uninstall_app \
        --name='lesspipe' \
        --unlink-in-bin='lesspipe.sh' \
        "$@"
}
