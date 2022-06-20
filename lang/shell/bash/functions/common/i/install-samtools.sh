#!/usr/bin/env bash

koopa_install_samtools() {
    koopa_install_app \
        --installer='conda-env' \
        --link-in-bin='bin/samtools' \
        --name='samtools' \
        "$@"
}
