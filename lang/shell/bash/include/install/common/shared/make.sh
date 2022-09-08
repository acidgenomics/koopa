#!/usr/bin/env bash

main() {
    koopa_install_app_subshell \
        --installer='gnu-app' \
        --name='make' \
        -D '--program-prefix=g' \
        "$@"
}
