#!/usr/bin/env bash

koopa_install_pipx() {
    koopa_install_app \
        --installer='python-venv' \
        --link-in-bin='bin/pipx' \
        --name='pipx' \
        "$@"
}
