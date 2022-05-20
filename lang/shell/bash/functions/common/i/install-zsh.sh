#!/usr/bin/env bash

koopa_install_zsh() {
    koopa_install_app \
        --link-in-bin='bin/zsh' \
        --name-fancy='Zsh' \
        --name='zsh' \
        "$@"
    koopa_fix_zsh_permissions
    return 0
}
