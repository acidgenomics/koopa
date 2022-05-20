#!/usr/bin/env bash

koopa_install_pyflakes() {
    koopa_install_app \
        --installer='python-venv' \
        --link-in-bin='bin/pyflakes' \
        --name='pyflakes' \
        "$@"
}
