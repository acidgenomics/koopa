#!/usr/bin/env bash

koopa_install_yapf() {
    koopa_install_app \
        --installer='python-package' \
        --name='yapf' \
        "$@"
}
