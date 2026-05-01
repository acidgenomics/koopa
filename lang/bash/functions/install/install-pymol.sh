#!/usr/bin/env bash

_koopa_install_pymol() {
    _koopa_assert_is_not_arm64
    _koopa_install_app \
        --name='pymol' \
        "$@"
}
