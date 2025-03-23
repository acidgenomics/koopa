#!/bin/sh

_koopa_spacevim() {
    # """
    # SpaceVim alias.
    # @note Updated 2023-05-09.
    # """
    __kvar_vim='vim'
    if _koopa_is_macos
    then
        __kvar_gvim='/Applications/MacVim.app/Contents/bin/gvim'
        [ -x "$__kvar_gvim" ] && __kvar_vim="$__kvar_gvim"
        unset -v __kvar_gvim
    fi
    __kvar_vimrc="$(_koopa_spacevim_prefix)/vimrc"
    if [ ! -f "$__kvar_vimrc" ]
    then
        _koopa_print 'SpaceVim is not installed.'
        return 1
    fi
    _koopa_is_alias 'vim' && unalias 'vim'
    "$__kvar_vim" -u "$__kvar_vimrc" "$@"
    unset -v __kvar_vim __kvar_vimrc
    return 0
}
