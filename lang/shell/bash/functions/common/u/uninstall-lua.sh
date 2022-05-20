#!/usr/bin/env bash

koopa_uninstall_lua() {
    koopa_uninstall_app \
        --name-fancy='Lua' \
        --name='lua' \
        "$@"
}
