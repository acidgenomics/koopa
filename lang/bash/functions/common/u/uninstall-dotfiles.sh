#!/usr/bin/env bash

# FIXME Need to rethink uninstallation of user dotfiles as well.

koopa_uninstall_dotfiles() {
    koopa_uninstall_app \
        --name='dotfiles' \
        "$@"
}
