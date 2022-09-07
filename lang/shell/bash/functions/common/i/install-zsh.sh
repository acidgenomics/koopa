#!/usr/bin/env bash

# FIXME Need to configure '/etc/shells' for shared install.

koopa_install_zsh() {
    koopa_install_app \
        --name='zsh' \
        "$@"
    # FIXME This should be handled during the install call.
    koopa_fix_zsh_permissions
    return 0
}
