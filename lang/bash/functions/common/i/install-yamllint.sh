#!/usr/bin/env bash

koopa_install_yamllint() {
    koopa_install_app \
        --installer='python-package' \
        --name='yamllint' \
        "$@"
}
