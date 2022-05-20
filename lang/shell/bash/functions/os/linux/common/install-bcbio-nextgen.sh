#!/usr/bin/env bash

koopa_linux_install_bcbio_nextgen() {
    koopa_install_app \
        --link-in-bin='tools/bin/bcbio_nextgen.py' \
        --name='bcbio-nextgen' \
        --platform='linux' \
        --version="$(koopa_current_bcbio_nextgen_version)" \
        "$@"
}
