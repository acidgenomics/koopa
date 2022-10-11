#!/usr/bin/env bash

main() {
    koopa_is_linux && koopa_activate_app 'attr'
    koopa_install_app_subshell \
        --installer='gnu-app' \
        --name='patch' \
        "$@"
}
