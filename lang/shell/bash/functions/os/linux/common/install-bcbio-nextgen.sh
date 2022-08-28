#!/usr/bin/env bash

koopa_linux_install_bcbio_nextgen() {
    koopa_install_app \
        --name='bcbio-nextgen' \
        --platform='linux' \
        --version="$(koopa_current_bcbio_nextgen_version)" \
        "$@"
}
