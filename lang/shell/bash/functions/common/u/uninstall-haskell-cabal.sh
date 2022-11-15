#!/usr/bin/env bash

koopa_uninstall_haskell_cabal() {
    koopa_uninstall_app \
        --name='haskell-cabal' \
        "$@"
}
