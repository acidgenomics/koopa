#!/usr/bin/env bash

koopa_install_difftastic() {
    if koopa_is_macos
    then
        koopa_assert_is_not_amd64
    fi
    koopa_install_app \
        --installer='conda-package' \
        --name='difftastic' \
        "$@"
}
