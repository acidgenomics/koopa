#!/usr/bin/env bash

main() {
    _koopa_activate_app 'zlib'
    _koopa_install_python_package \
        --egg-name='ont_bonito' \
        --python-version='3.13'
    return 0
}
