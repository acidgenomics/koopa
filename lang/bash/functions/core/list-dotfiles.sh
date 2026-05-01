#!/usr/bin/env bash

_koopa_list_dotfiles() {
    # """
    # List dotfiles.
    # @note Updated 2022-02-17.
    # """
    _koopa_assert_has_no_args "$#"
    _koopa_h1 "Listing dotfiles in '${HOME:?}'."
    _koopa_find_dotfiles 'd' 'Directories'
    _koopa_find_dotfiles 'f' 'Files'
    _koopa_find_dotfiles 'l' 'Symlinks'
}
