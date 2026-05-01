#!/usr/bin/env bash

_koopa_locate_cabal() {
    _koopa_locate_app \
        --app-name='haskell-cabal' \
        --bin-name='cabal' \
        "$@"
}
