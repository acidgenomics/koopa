#!/usr/bin/env bash

_koopa_install_zsh() {
    local -A dict
    _koopa_install_app \
        --installer='conda-package' \
        --name='zsh' \
        "$@"
    dict['zsh']="$(_koopa_app_prefix 'zsh')"
    _koopa_chmod --recursive 'g-w' "${dict['zsh']}/share/zsh"
    return 0
}
