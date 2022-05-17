#!/usr/bin/env bash

koopa_install_flake8() {
    koopa_install_app \
        --installer='python-venv' \
        --link-in-bin='bin/flake8' \
        --name='flake8' \
        "$@"
}
