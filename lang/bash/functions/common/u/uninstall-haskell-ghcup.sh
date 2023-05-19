#!/usr/bin/env bash

koopa_uninstall_haskell_ghcup() {
    koopa_uninstall_app \
        --name='haskell-ghcup' \
        "$@"
}
