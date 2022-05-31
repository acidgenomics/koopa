#!/usr/bin/env bash

koopa_uninstall_sox() {
    koopa_uninstall_app \
        --name-fancy='SoX' \
        --name='sox' \
        --unlink-in-bin='sox' \
        "$@"
}
