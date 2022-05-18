#!/usr/bin/env bash

koopa_install_ranger_fm() {
    koopa_install_app \
        --installer='python-venv' \
        --link-in-bin='bin/ranger' \
        --name='ranger-fm' \
        "$@"
}
