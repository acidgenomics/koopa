#!/usr/bin/env bash

koopa_macos_install_neovim_binary() {
    koopa_install_app \
        --installer='neovim-binary' \
        --link-in-bin='bin/nvim' \
        --name-fancy='Neovim' \
        --name='neovim' \
        --platform='macos' \
        "$@"
}
