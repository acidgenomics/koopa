#!/usr/bin/env bash

_koopa_uninstall_luarocks() {
    _koopa_uninstall_app \
        --name='luarocks' \
        "$@"
}
