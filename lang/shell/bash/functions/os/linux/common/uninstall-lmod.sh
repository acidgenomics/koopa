#!/usr/bin/env bash

# FIXME Need to clean up 'etc/profile.d'

koopa_linux_uninstall_lmod() {
    koopa_uninstall_app \
        --name-fancy='Lmod' \
        --name='lmod' \
        --platform='linux' \
        "$@"
    return 0
}
