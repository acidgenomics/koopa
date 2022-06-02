#!/usr/bin/env bash

koopa_install_latch() {
    koopa_install_app \
        --installer='python-venv' \
        --link-in-bin='bin/latch' \
        --name-fancy='LatchBio SDK' \
        --name='latch' \
        "$@"
}
