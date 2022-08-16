#!/usr/bin/env bash

main() {
    koopa_install_app \
        --installer='python-venv' \
        --name='meson' \
        "$@"
}
