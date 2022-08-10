#!/usr/bin/env bash

koopa_uninstall_bustools() {
    koopa_uninstall_app \
        --name='bustools' \
        --unlink-in-bin='bustools' \
        "$@"
}
