#!/usr/bin/env bash

koopa_install_meson() {
    koopa_install_app \
        --installer='python-venv' \
        --name-fancy='Meson' \
        --name='meson' \
        "$@"
}
