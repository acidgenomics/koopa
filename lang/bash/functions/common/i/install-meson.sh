#!/usr/bin/env bash

koopa_install_meson() {
    koopa_install_app \
        --installer='python-package' \
        --name='meson' \
        "$@"
}
