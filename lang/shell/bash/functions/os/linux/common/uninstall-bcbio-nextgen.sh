#!/usr/bin/env bash

koopa_linux_uninstall_bcbio_nextgen() {
    koopa_uninstall_app \
        --name='bcbio-nextgen' \
        --platform='linux' \
        --unlink-in-bin='bcbio_nextgen.py' \
        "$@"
}
