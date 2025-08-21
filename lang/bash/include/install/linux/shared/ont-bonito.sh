#!/usr/bin/env bash

main() {
    koopa_activate_app 'zlib'
    koopa_install_python_package \
        --egg-name='ont_bonito' \
        --python-version='3.13'
    return 0
}
