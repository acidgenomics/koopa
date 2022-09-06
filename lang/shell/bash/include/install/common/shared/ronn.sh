#!/usr/bin/env bash

main() {
    koopa_install_app_passthrough \
        --installer='ruby-package' \
        --name='ronn' \
        "$@"
}
