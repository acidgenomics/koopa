#!/usr/bin/env bash

main() {
    koopa_activate_app 'taglib'
    koopa_install_app_subshell \
        --installer='python-venv' \
        --name='pytaglib' \
        -D '--no-binary' \
        -D '--python-version=3.10' \
        -D 'tqdm'
}
