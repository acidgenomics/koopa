#!/usr/bin/env bash

main() {
    koopa_install_app_passthrough \
        --installer='gnu-app' \
        --name='tar' \
        -D '--program-prefix=g' \
        "$@"
}
