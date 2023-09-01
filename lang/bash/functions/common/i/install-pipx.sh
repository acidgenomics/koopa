#!/usr/bin/env bash

koopa_install_pipx() {
    koopa_install_app \
        --installer='python-package' \
        --name='pipx' \
        "$@"
}
