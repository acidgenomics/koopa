#!/usr/bin/env bash

koopa_install_glances() {
    koopa_install_app \
        --installer='python-package' \
        --name='glances' \
        -D --egg-name='Glances' \
        "$@"
}
