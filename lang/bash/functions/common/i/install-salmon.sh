#!/usr/bin/env bash

koopa_install_salmon() {
    if koopa_is_macos && koopa_is_aarch64
    then
        koopa_install_app \
            --name='salmon' \
            "$@"
    else
        koopa_install_app \
            --installer='conda-package' \
            --name='salmon' \
            "$@"
    fi
}
