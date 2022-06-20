#!/usr/bin/env bash

koopa_install_bedtools() {
    koopa_install_app \
        --installer='conda-env' \
        --link-in-bin='bin/bedtools' \
        --name='bedtools' \
        "$@"
}
