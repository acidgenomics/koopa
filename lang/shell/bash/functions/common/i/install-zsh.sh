#!/usr/bin/env bash

koopa_install_zsh() {
    koopa_install_app \
        --name='zsh' \
        "$@"
    # FIXME This should be handled during the install call.
    koopa_fix_zsh_permissions
    koopa_enable_shell_for_all_users 'zsh'
    return 0
}
