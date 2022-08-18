#!/usr/bin/env bash

koopa_install_fastqc() {
    koopa_install_app \
        --link-in-bin='fastqc' \
        --name='fastqc' \
        "$@"
}
