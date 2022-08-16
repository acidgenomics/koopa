#!/usr/bin/env bash

koopa_install_pyflakes() {
    koopa_install_app \
        --link-in-bin='pyflakes' \
        --name='pyflakes' \
        "$@"
}
