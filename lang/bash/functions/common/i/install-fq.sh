#!/usr/bin/env bash

koopa_install_fq() {
    koopa_install_app \
        --installer='conda-package' \
        --name='fq' \
        "$@"
}
