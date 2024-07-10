#!/usr/bin/env bash

koopa_install_scanpy() {
    koopa_install_app \
        --installer='python-package' \
        --name='scanpy' \
        "$@"
}
