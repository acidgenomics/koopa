#!/usr/bin/env bash

_koopa_install_bedtools() {
    if _koopa_is_macos && _koopa_is_arm64
    then
        _koopa_install_app \
            --name='bedtools' \
            "$@"
    else
        _koopa_install_app \
            --installer='conda-package' \
            --name='bedtools' \
            "$@"
    fi
}
