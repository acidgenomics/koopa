#!/usr/bin/env bash

_koopa_install_conda() {
    if _koopa_is_macos && _koopa_is_amd64
    then
        _koopa_stop 'Conda build support for Intel Macs is now deprecated.'
    fi
    _koopa_install_app \
        --name='conda' \
        "$@"
}
