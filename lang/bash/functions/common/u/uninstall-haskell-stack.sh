#!/usr/bin/env bash

koopa_uninstall_haskell_stack() {
    koopa_uninstall_app \
        --name='haskell-stack' \
        "$@"
}
