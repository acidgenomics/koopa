#!/usr/bin/env bash

main() {
    koopa_install_app_passthrough \
        --installer='gnu-app' \
        --name='make' \
        -D '--program-prefix=g' \
        "$@"
}
