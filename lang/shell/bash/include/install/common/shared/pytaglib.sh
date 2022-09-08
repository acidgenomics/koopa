#!/usr/bin/env bash

main() {
    koopa_activate_opt_prefix 'taglib'
    koopa_install_app_subshell \
        --installer='python-venv' \
        --name='pytaglib' \
        "$@"
}
