#!/usr/bin/env bash

# Clean install is still hitting this coc / yarn permission issue.

koopa_install_neovim() {
    koopa_install_app \
        --link-in-bin='nvim' \
        --name='neovim' \
        "$@"
}
