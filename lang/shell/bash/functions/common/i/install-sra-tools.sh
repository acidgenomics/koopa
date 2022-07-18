#!/usr/bin/env bash

koopa_install_sra_tools() {
    koopa_install_app \
        --link-in-bin='fasterq-dump' \
        --link-in-bin='vdb-config' \
        --name='sra-tools' \
        "$@"
}
