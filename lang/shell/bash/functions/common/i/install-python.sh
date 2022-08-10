#!/usr/bin/env bash

koopa_install_python() {
    koopa_install_app \
        --link-in-bin='python3' \
        --name='python' \
        "$@"
}
