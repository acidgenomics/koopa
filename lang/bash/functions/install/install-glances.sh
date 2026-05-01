#!/usr/bin/env bash

_koopa_install_glances() {
    _koopa_install_app \
        --installer='python-package' \
        --name='glances' \
        -D --egg-name='Glances' \
        "$@"
}
