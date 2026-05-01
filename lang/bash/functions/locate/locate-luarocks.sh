#!/usr/bin/env bash

_koopa_locate_luarocks() {
    _koopa_locate_app \
        --app-name='luarocks' \
        --bin-name='luarocks' \
        "$@"
}
