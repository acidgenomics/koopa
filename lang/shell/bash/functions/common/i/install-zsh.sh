#!/usr/bin/env bash

koopa_install_zsh() {
    local -A dict
    koopa_install_app --name='zsh' "$@"
    dict['zsh']="$(koopa_app_prefix 'zsh')"
    koopa_chmod --recursive 'g-w' "${dict['zsh']}/share/zsh"
    # > koopa_enable_shell_for_all_users "$(koopa_bin_prefix)/zsh"
    return 0
}
