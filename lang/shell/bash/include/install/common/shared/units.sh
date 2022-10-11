#!/usr/bin/env bash

main() {
    koopa_activate_app 'readline'
    koopa_install_app_subshell \
        --installer='gnu-app' \
        --name='units' \
        -D '--program-prefix=g' \
        "$@"

}
