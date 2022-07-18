#!/usr/bin/env bash

koopa_install_bpytop() {
    koopa_install_app \
        --installer='python-venv' \
        --link-in-bin='bpytop' \
        --name='bpytop' \
        "$@"
}
