#!/usr/bin/env bash

koopa_install_samtools() {
    koopa_install_app \
        --link-in-bin='samtools' \
        --name='samtools' \
        "$@"
}
