#!/usr/bin/env bash

_koopa_linux_uninstall_bcbio_nextgen() {
    _koopa_uninstall_app \
        --name='bcbio-nextgen' \
        --platform='linux' \
        "$@"
}
