#!/usr/bin/env bash

koopa_install_uv() {
    koopa_install_app \
        --installer='python-package' \
        --name='uv' \
        "$@"
}
