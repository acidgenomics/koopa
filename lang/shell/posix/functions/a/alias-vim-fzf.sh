#!/bin/sh

koopa_alias_vim_fzf() {
    # """
    # Pipe FZF output to Vim.
    # @note Updated 2021-06-08.
    # """
    vim "$(fzf)"
}
