#!/usr/bin/env bash

# NOTE Consider resetting default shell here, if necessary.

koopa_uninstall_zsh() {
    koopa_uninstall_app \
        --name-fancy="Zsh" \
        --name='zsh' \
        --unlink-in-bin='zsh' \
        "$@"
}
