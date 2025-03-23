#!/usr/bin/env bash

koopa_install_shellcheck() {
    koopa_install_app \
        --installer='conda-package' \
        --name='shellcheck' \
        "$@"
}
