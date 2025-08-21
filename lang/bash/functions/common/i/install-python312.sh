#!/usr/bin/env bash

koopa_install_python312() {
    koopa_install_app \
        --installer='python' \
        --name='python3.12' \
        "$@"
}
