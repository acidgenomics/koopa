#!/usr/bin/env bash

koopa_uninstall_sra_tools() {
    koopa_uninstall_app \
        --name-fancy='SRA Toolkit' \
        --name='sra-tools' \
        --unlink-in-bin='fasterq-dump' \
        "$@"
}
