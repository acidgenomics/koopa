#!/usr/bin/env bash

main() {
    koopa_install_app_passthrough \
        --installer='node-package' \
        --name='bash-language-server' \
        "$@"
}
