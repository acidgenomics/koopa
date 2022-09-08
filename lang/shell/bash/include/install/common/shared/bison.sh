#!/usr/bin/env bash

main() {
    koopa_activate_opt_prefix 'm4'
    koopa_install_app_subshell \
        --installer='gnu-app' \
        --name='bison' \
        -D '--enable-relocatable' \
        "$@"
}
