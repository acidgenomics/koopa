#!/usr/bin/env bash

koopa_install_pytest() {
    koopa_install_app \
        --installer='python-package' \
        --name='pytest' \
        "$@"
}
