#!/usr/bin/env bash

koopa_uninstall_neovim() {
    koopa_uninstall_app \
        --name='neovim' \
        --unlink-in-bin='nvim' \
        "$@"
}
