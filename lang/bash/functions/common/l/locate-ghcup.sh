#!/usr/bin/env bash

koopa_locate_ghcup() {
    koopa_locate_app \
        --app-name='haskell-ghcup' \
        --bin-name='ghcup' \
        "$@"
}
