#!/usr/bin/env bash

# NOTE Consider installing pytest-cov plugin here too.

koopa_install_pytest() {
    koopa_install_app \
        --installer='python-package' \
        --name='pytest' \
        "$@"
}
