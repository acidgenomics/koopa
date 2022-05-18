#!/usr/bin/env bash

koopa_install_ninja() {
    koopa_install_app \
        --installer='python-venv' \
        --name-fancy='Ninja' \
        --name='ninja' \
        "$@"
}
