#!/usr/bin/env bash

_koopa_install_misopy() {
    _koopa_assert_is_not_arm64
    _koopa_install_app \
        --installer='conda-package' \
        --name='misopy' \
        "$@"
}
