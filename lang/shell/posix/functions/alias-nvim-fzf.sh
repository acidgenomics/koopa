#!/bin/sh

koopa_alias_nvim_fzf() {
    # """
    # Pipe FZF output to Neovim.
    # @note Updated 2022-04-08.
    # """
    nvim "$(fzf)"
}
