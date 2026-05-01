#!/usr/bin/env bash

_koopa_locate_ghcup() {
    _koopa_locate_app \
        --app-name='haskell-ghcup' \
        --bin-name='ghcup' \
        "$@"
}
