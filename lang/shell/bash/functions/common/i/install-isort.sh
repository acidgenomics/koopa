#!/usr/bin/env bash

koopa_install_isort() {
    koopa_install_app \
        --installer='python-venv' \
        --link-in-bin='bin/isort' \
        --name='isort' \
        "$@"
}
