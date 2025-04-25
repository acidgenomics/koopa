#!/bin/sh

_koopa_export_manpager() {
    # """
    # Export 'MANPAGER' variable.
    # @note Updated 2025-04-24.
    #
    # Alternatively can use 'less --incsearch'.
    #
    # @seealso
    # - https://www.reddit.com/r/neovim/comments/1k1k9bz/
    #     use_neovim_as_the_default_man_page_viewer/
    # """
    [ -n "${MANPAGER:-}" ] && return 0
    __kvar_nvim="$(_koopa_bin_prefix)/nvim"
    if [ -x "$__kvar_nvim" ]
    then
        export MANPAGER="${__kvar_nvim} +Man!"
    fi
    unset -v __kvar_nvim
    return 0
}
