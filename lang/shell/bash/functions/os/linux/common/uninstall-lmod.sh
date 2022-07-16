#!/usr/bin/env bash

koopa_linux_uninstall_lmod() {
    koopa_uninstall_app \
        --name='lmod' \
        --platform='linux' \
        "$@"
    return 0
}
