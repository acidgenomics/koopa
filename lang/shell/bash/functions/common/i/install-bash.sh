#!/usr/bin/env bash

koopa_install_bash() {
    koopa_install_app \
        --name='bash' \
        "$@"
    koopa_enable_shell_for_all_users 'bash'
    return 0
}
