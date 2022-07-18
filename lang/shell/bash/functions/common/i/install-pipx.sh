#!/usr/bin/env bash

koopa_install_pipx() {
    koopa_install_app \
        --installer='python-venv' \
        --link-in-bin='pipx' \
        --name='pipx' \
        "$@"
}
