#!/usr/bin/env bash

koopa_install_fastqc() {
    koopa_install_app \
        --installer='conda-env' \
        --link-in-bin='fastqc' \
        --name='fastqc' \
        "$@"
}
