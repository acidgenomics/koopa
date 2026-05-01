#!/usr/bin/env bash

_koopa_uninstall_haskell_stack() {
    _koopa_uninstall_app \
        --name='haskell-stack' \
        "$@"
}
