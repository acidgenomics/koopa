#!/usr/bin/env bash

koopa_install_scons() {
    koopa_install_app \
        --installer='python-venv' \
        --name-fancy='SCONS' \
        --name='scons' \
        "$@"
}
