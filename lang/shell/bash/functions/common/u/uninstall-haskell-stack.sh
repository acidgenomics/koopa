#!/usr/bin/env bash

koopa_uninstall_haskell_stack() {
    koopa_uninstall_app \
        --name-fancy='Haskell Stack' \
        --name='haskell-stack' \
        "$@"
}
