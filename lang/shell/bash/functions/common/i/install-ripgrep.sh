#!/usr/bin/env bash

koopa_install_ripgrep() {
    koopa_install_app \
        --activate-opt='pcre2' \
        --installer='rust-package' \
        --link-in-bin='rg' \
        --name='ripgrep' \
        "$@"
}
