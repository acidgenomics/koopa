#!/usr/bin/env bash

main() {
    koopa_install_app_passthrough \
        --name='bat' \
        --installer='rust-package' \
        "$@"
}
