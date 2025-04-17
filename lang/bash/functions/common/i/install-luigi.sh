#!/usr/bin/env bash

koopa_install_luigi() {
    koopa_install_app \
        --installer='python-package' \
        --name='luigi' \
        -D --pip-name='luigi[toml]' \
        "$@"
}
