#!/usr/bin/env bash

koopa_install_julia() {
    koopa_assert_is_not_aarch64
    koopa_install_app \
        --name='julia' \
        "$@"
}
