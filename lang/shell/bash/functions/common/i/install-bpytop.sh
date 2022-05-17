#!/usr/bin/env bash

koopa_install_bpytop() {
    koopa_install_app \
        --installer='python-venv' \
        --link-in-bin='bin/bpytop' \
        --name='bpytop' \
        "$@"
}
