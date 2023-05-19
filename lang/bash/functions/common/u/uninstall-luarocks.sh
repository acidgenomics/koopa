#!/usr/bin/env bash

koopa_uninstall_luarocks() {
    koopa_uninstall_app \
        --name='luarocks' \
        "$@"
}
