#!/usr/bin/env bash

# FIXME Ensure that this cleans up 'etc/profile.d'

koopa_linux_uninstall_lmod() {
    koopa_uninstall_app \
        --name-fancy='Lmod' \
        --name='lmod' \
        --platform='linux' \
        "$@"
    return 0
}
