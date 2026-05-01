#!/usr/bin/env bash

_koopa_install_difftastic() {
    if _koopa_is_macos
    then
        _koopa_assert_is_not_amd64
    fi
    _koopa_install_app \
        --installer='conda-package' \
        --name='difftastic' \
        "$@"
}
