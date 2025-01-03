#!/usr/bin/env bash

koopa_install_bustools() {
    koopa_assert_is_not_arm64
    koopa_install_app \
        --installer='conda-package' \
        --name='bustools' \
        "$@"
}
