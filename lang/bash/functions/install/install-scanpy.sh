#!/usr/bin/env bash

_koopa_install_scanpy() {
    _koopa_install_app \
        --installer='python-package' \
        --name='scanpy' \
        "$@"
}
