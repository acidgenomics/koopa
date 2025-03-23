#!/usr/bin/env bash

koopa_install_bedtools() {
    if koopa_is_macos && koopa_is_arm64
    then
        koopa_install_app \
            --name='bedtools' \
            "$@"
    else
        koopa_install_app \
            --installer='conda-package' \
            --name='bedtools' \
            "$@"
    fi
}
