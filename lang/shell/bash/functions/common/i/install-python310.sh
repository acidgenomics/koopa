#!/usr/bin/env bash

koopa_install_python310() {
    koopa_install_app \
        --installer='python' \
        --name='python3.10' \
        "$@"
}
