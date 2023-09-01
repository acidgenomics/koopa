#!/usr/bin/env bash

koopa_install_autoflake() {
    koopa_install_app \
        --installer='python-package' \
        --name='autoflake' \
        "$@"
}
