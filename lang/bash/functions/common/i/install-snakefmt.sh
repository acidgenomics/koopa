#!/usr/bin/env bash

koopa_install_snakefmt() {
    koopa_install_app \
        --installer='python-package' \
        --name='snakefmt' \
        "$@"
}
