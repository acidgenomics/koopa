#!/usr/bin/env bash

koopa_install_fastqc() {
    koopa_install_app \
        --installer='conda-package' \
        --name='fastqc' \
        "$@"
}
