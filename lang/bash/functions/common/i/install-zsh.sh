#!/usr/bin/env bash

koopa_install_zsh() {
    local -A dict
    koopa_install_app \
        --installer='conda-package' \
        --name='zsh' \
        "$@"
    dict['zsh']="$(koopa_app_prefix 'zsh')"
    koopa_chmod --recursive 'g-w' "${dict['zsh']}/share/zsh"
    return 0
}
