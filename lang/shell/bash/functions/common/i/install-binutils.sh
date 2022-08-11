#!/usr/bin/env bash

koopa_install_binutils() {
    # """
    # Consider adding '--activate-opt=zlib'.
    # """
    koopa_install_app \
        --activate-build-opt='texinfo' \
        --installer='gnu-app' \
        --name='binutils' \
        "$@"
}
