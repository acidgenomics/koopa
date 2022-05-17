#!/usr/bin/env bash

koopa_uninstall_bat() {
    koopa_uninstall_app \
        --name='bat' \
        --unlink-in-bin='bat' \
        "$@"
}
