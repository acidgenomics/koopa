#!/usr/bin/env bash

koopa_locate_cabal() {
    koopa_locate_app \
        --app-name='haskell-cabal' \
        --bin-name='cabal' \
        "$@"
}
