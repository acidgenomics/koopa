#!/usr/bin/env bash

koopa_install_latch() {
    koopa_install_app \
        --installer='python-venv' \
        --link-in-bin='latch' \
        --name='latch' \
        "$@"
}
