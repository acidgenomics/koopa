#!/usr/bin/env bash

# FIXME This is currently failing to install with Python 3.11.0.

main() {
    koopa_activate_app 'taglib'
    koopa_install_app_subshell \
        --installer='python-venv' \
        --name='pytaglib' \
        "$@"
}
