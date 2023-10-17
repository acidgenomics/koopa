#!/usr/bin/env bash

koopa_install_ffq() {
    koopa_assert_is_not_aarch64
    koopa_install_app \
        --installer='conda-package' \
        --name='ffq' \
        "$@"
}
