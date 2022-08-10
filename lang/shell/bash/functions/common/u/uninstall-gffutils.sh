#!/usr/bin/env bash

koopa_uninstall_gffutils() {
    koopa_uninstall_app \
        --name='gffutils' \
        --unlink-in-bin='gffutils-cli' \
        "$@"
}
