#!/usr/bin/env bash

_koopa_install_meson() {
    _koopa_install_app \
        --installer='python-package' \
        --name='meson' \
        "$@"
}
