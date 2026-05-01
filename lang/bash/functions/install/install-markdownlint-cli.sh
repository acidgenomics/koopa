#!/usr/bin/env bash

_koopa_install_markdownlint_cli() {
    _koopa_install_app \
        --installer='node-package' \
        --name='markdownlint-cli' \
        "$@"
}
