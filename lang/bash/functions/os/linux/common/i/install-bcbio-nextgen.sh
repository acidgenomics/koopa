#!/usr/bin/env bash

koopa_linux_install_bcbio_nextgen() {
    koopa_assert_is_not_aarch64
    koopa_install_app \
        --name='bcbio-nextgen' \
        --platform='linux' \
        "$@"
}
