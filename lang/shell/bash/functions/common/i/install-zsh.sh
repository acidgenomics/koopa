#!/usr/bin/env bash

koopa_install_zsh() {
    koopa_install_app \
        --link-in-bin='zsh' \
        --name='zsh' \
        "$@"
    koopa_fix_zsh_permissions
    return 0
}
