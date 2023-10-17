#!/usr/bin/env bash

koopa_install_kallisto() {
    if koopa_is_macos && koopa_is_aarch64
    then
        koopa_install_app \
            --name='kallisto' \
            "$@"
    else
        koopa_install_app \
            --installer='conda-package' \
            --name='kallisto' \
            "$@"
    fi
}
