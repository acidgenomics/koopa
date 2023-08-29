#!/usr/bin/env bash

koopa_install_markdownlint_cli() {
    koopa_install_app \
        --installer='node-package' \
        --name='markdownlint-cli' \
        "$@"
}
