#!/usr/bin/env bash

koopa_install_markdown() {
    koopa_install_app \
        --installer='nim-package' \
        --link-in-bin='bin/markdown' \
        --name='markdown' \
        "$@"
}
