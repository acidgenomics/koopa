#!/usr/bin/env bash

koopa_uninstall_ripgrep() {
    koopa_uninstall_app \
        --unlink-in-bin='rg' \
        --name='ripgrep' \
        "$@"
}
