#!/usr/bin/env bash

koopa_install_commitizen() {
    koopa_install_app \
        --installer='python-package' \
        --name='commitizen' \
        "$@"
}
