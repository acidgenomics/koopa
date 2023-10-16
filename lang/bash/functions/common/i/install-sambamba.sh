#!/usr/bin/env bash

koopa_install_sambamba() {
    if koopa_is_macos && koopa_is_aarch64
    then
        koopa_install_app \
            --name='sambamba' \
            "$@"
    else
        koopa_install_app \
            --installer='conda-package' \
            --name='sambamba' \
            "$@"
    fi
}
