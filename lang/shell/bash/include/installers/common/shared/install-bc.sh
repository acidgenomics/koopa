#!/usr/bin/env bash

main() {
    koopa_install_app_internal \
        --activate-build-opt='texinfo' \
        --installer='gnu-app' \
        --name='bc' \
        "$@"
}
