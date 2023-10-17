#!/usr/bin/env bash

koopa_install_gcc() {
    if koopa_is_macos && koopa_is_x86_64
    then
        koopa_stop 'Unsupported platform.'
    fi
    koopa_install_app \
        --name='gcc' \
        "$@"
}
