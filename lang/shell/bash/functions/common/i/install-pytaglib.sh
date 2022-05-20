#!/usr/bin/env bash

koopa_install_pytaglib() {
    koopa_install_app \
        --link-in-bin='bin/pyprinttags' \
        --activate-opt='taglib' \
        --installer='python-venv' \
        --name='pytaglib' \
        "$@"
}
