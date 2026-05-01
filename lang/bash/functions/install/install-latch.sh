#!/usr/bin/env bash

_koopa_install_latch() {
    _koopa_install_app \
        --installer='python-package' \
        --name='latch' \
        -D --python-version='3.12' \
        "$@"
}
