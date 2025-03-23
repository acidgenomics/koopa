#!/usr/bin/env bash

koopa_install_fastqc() {
    koopa_assert_is_not_arm64
    koopa_install_app \
        --installer='conda-package' \
        --name='fastqc' \
        "$@"
}
