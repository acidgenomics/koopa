#!/usr/bin/env bash

_koopa_install_bamtools() {
    _koopa_assert_is_not_arm64
    _koopa_install_app \
        --installer='conda-package' \
        --name='bamtools' \
        "$@"
}
