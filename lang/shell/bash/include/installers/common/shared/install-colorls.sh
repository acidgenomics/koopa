#!/usr/bin/env bash

main() {
    koopa_install_app_internal \
        --installer='ruby-package' \
        --name='colorls' \
        "$@"
}
