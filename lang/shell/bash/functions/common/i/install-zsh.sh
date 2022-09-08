#!/usr/bin/env bash

koopa_install_zsh() {
    koopa_install_app \
        --name='zsh' \
        "$@"
    koopa_fix_zsh_permissions
    koopa_enable_shell_for_all_users "$(koopa_bin_prefix)/zsh"
    return 0
}
