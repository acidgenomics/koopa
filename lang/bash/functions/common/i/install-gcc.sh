#!/usr/bin/env bash

# FIXME Skip on macOS Sonoma x86_64.

koopa_install_gcc() {
    koopa_install_app \
        --name='gcc' \
        "$@"
}
