#!/usr/bin/env bash

koopa_install_conda() {
    if koopa_is_macos && koopa_is_amd64
    then
        koopa_stop 'Conda build support for Intel Macs is now deprecated.'
    fi
    koopa_install_app \
        --name='conda' \
        "$@"
}
