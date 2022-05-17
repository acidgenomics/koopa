#!/usr/bin/env bash

koopa_uninstall_boost() {
    koopa_uninstall_app \
        --name-fancy='Boost' \
        --name='boost' \
        "$@"
}
