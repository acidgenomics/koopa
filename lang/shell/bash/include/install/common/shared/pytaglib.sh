#!/usr/bin/env bash

main() {
    koopa_activate_opt_prefix 'taglib'
    koopa_install_app_internal \
        --installer='python-venv' \
        --name='pytaglib' \
        "$@"
}
