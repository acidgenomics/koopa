#!/usr/bin/env bash

_koopa_install_scons() {
    _koopa_install_app \
        --installer='python-package' \
        --name='scons' \
        -D --egg-name='SCons' \
        "$@"
}
