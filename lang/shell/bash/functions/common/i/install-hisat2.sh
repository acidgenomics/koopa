#!/usr/bin/env bash

koopa_install_hisat2() {
    koopa_install_app \
        --installer='conda-env' \
        --link-in-bin='hisat2' \
        --name='hisat2' \
        "$@"
}
