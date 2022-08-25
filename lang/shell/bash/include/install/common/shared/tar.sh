#!/usr/bin/env bash

main() {
    koopa_install_app_internal \
        --installer='gnu-app' \
        --name='tar' \
        -D '--program-prefix=g' \
        "$@"
}
