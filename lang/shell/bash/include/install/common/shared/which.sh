#!/usr/bin/env bash

main() {
    koopa_install_app_subshell \
        --installer='gnu-app' \
        --name='which' \
        -D '--program-prefix=g' \
        "$@"
}
