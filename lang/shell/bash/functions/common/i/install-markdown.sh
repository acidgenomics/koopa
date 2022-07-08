#!/usr/bin/env bash

# FIXME This seems to be hanging with isolated nim install.

koopa_install_markdown() {
    koopa_install_app \
        --installer='nim-package' \
        --link-in-bin='bin/markdown' \
        --name='markdown' \
        "$@"
}
