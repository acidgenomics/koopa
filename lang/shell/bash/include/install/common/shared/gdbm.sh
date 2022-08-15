#!/usr/bin/env bash

main() {
    koopa_activate_opt_prefix 'readline'
    koopa_install_app_internal \
        --installer='gnu-app' \
        --name='gdbm' \
        "$@"
}
