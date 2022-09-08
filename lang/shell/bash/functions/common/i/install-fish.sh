#!/usr/bin/env bash

# FIXME Need to configure '/etc/shells' for shared install.

koopa_install_fish() {
    koopa_install_app \
        --name='fish' \
        "$@"
    koopa_enable_shell_for_all_users 'fish'
    return 0
}
