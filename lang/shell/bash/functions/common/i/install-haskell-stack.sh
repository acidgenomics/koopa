#!/usr/bin/env bash

koopa_install_haskell_stack() {
    koopa_install_app \
        --name-fancy='Haskell Stack' \
        --name='haskell-stack' \
        "$@"
}
