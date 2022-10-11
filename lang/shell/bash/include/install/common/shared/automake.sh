#!/usr/bin/env bash

main() {
    koopa_activate_app 'autoconf'
    koopa_install_app_subshell \
        --installer='gnu-app' \
        --name='automake' \
        "$@"
}
