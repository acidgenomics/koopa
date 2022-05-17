#!/usr/bin/env bash

koopa_install_black() {
    koopa_install_app \
        --installer='python-venv' \
        --link-in-bin='bin/black' \
        --name='black' \
        "$@"
}
