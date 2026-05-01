#!/usr/bin/env bash

_koopa_install_yapf() {
    _koopa_install_app \
        --installer='python-package' \
        --name='yapf' \
        "$@"
}
