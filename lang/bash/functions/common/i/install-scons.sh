#!/usr/bin/env bash

koopa_install_scons() {
    koopa_install_app \
        --installer='python-package' \
        --name='scons' \
        -D --egg-name='SCons' \
        "$@"
}
