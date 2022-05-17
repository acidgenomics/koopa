#!/usr/bin/env bash

koopa_uninstall_gcc() {
    koopa_uninstall_app \
        --name-fancy='GCC' \
        --name='gcc' \
        "$@"
}
