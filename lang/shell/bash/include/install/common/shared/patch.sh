#!/usr/bin/env bash

main() {
    koopa_is_linux && koopa_activate_opt_prefix 'attr'
    koopa_install_app_internal \
        --installer='gnu-app' \
        --name='patch' \
        "$@"
}
