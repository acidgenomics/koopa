#!/usr/bin/env bash

koopa_uninstall_sra_tools() {
    koopa_uninstall_app \
        --name='sra-tools' \
        --unlink-in-bin='fasterq-dump' \
        --unlink-in-bin='vdb-config' \
        "$@"
}
