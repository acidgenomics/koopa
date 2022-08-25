#!/usr/bin/env bash

main() {
    koopa_install_app_internal \
        --installer='gnu-app' \
        --name='sed' \
        -D '--program-prefix=g' \
        "$@"
}
