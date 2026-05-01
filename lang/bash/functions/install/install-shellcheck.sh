#!/usr/bin/env bash

_koopa_install_shellcheck() {
    _koopa_install_app \
        --installer='conda-package' \
        --name='shellcheck' \
        "$@"
}
