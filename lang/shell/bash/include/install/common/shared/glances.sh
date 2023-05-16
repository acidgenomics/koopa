#!/usr/bin/env bash

main() {
    koopa_activate_app 'ncurses'
    koopa_install_app_subshell \
        --installer='python-venv' \
        --name='glances' \
        -D '--no-binary'
}
