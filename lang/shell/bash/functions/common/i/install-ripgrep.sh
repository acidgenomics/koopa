#!/usr/bin/env bash

# FIXME Break out to separate installer. Don't use '--activate-opt' here, as
# it can cause issues with binary package install.

koopa_install_ripgrep() {
    koopa_install_app \
        --activate-opt='pcre2' \
        --installer='rust-package' \
        --link-in-bin='rg' \
        --name='ripgrep' \
        "$@"
}
