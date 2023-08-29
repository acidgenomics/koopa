#!/usr/bin/env bash

koopa_install_seqkit() {
    koopa_install_app \
        --installer='conda-package' \
        --name='seqkit' \
        "$@"
}
