#!/usr/bin/env bash

koopa_install_glances() {
    koopa_install_app \
        --installer='python-venv' \
        --link-in-bin='glances' \
        --name='glances' \
        "$@"
}
