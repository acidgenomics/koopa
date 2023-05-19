#!/usr/bin/env bash

koopa_list_dotfiles() {
    # """
    # List dotfiles.
    # @note Updated 2022-02-17.
    # """
    koopa_assert_has_no_args "$#"
    koopa_h1 "Listing dotfiles in '${HOME:?}'."
    koopa_find_dotfiles 'd' 'Directories'
    koopa_find_dotfiles 'f' 'Files'
    koopa_find_dotfiles 'l' 'Symlinks'
}
