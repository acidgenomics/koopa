#!/usr/bin/env bash

koopa_install_gatk() {
    koopa_assert_is_not_arm64
    koopa_install_app \
        --name='gatk' \
        "$@"
}
