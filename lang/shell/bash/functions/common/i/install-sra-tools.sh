#!/usr/bin/env bash

koopa_install_sra_tools() {
    koopa_install_app \
        --link-in-bin='bin/fasterq-dump' \
        --link-in-bin='bin/vdb-config' \
        --name-fancy='SRA Toolkit' \
        --name='sra-tools' \
        "$@"
}
