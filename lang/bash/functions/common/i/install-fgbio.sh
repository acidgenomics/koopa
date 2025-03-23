#!/usr/bin/env bash

koopa_install_fgbio() {
    koopa_install_app \
        --installer='conda-package' \
        --name='fgbio' \
        "$@"
}
