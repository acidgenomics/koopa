#!/usr/bin/env bash

# FIXME prettier isn't detecting globally installed plugins correctly:
# prettier --plugin '/opt/koopa/opt/prettier/lib/node_modules/prettier-plugin-sort-json/dist/index.js' --help

main() {
    koopa_install_app_subshell \
        --installer='node-package' \
        --name='prettier' \
        -D 'prettier-plugin-sort-json@3.0.0'
}
