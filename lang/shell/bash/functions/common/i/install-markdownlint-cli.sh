#!/usr/bin/env bash

koopa_install_markdownlint_cli() {
    koopa_install_app \
        --link-in-bin='markdownlint' \
        --name='markdownlint-cli' \
        "$@"
}
