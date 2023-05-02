#!/usr/bin/env bash

# FIXME We need to patch the latest release to fix app.py.
# Run this inside virtual environment:
# python3 setup.py install

main() {
    koopa_install_app_subshell \
        --installer='python-venv' \
        --name='radian'
}
