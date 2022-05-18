#!/usr/bin/env bash

koopa_install_neovim() {
    koopa_install_app \
        --link-in-bin='bin/nvim' \
        --name='neovim' \
        "$@"
}
