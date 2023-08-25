#!/usr/bin/env bash

main() {
    koopa_install_app_subshell \
        --installer='node-package' \
        --name='prettier' \
        -D 'prettier-plugin-sort-json@3.0.0'
}
