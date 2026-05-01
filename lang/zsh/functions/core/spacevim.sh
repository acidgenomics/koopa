#!/usr/bin/env zsh

_koopa_spacevim() {
    local vim
    vim='vim'
    if _koopa_is_macos
    then
        local gvim
        gvim='/Applications/MacVim.app/Contents/bin/gvim'
        [[ -x "$gvim" ]] && vim="$gvim"
    fi
    local vimrc
    vimrc="$(_koopa_spacevim_prefix)/vimrc"
    if [[ ! -f "$vimrc" ]]
    then
        _koopa_print 'SpaceVim is not installed.'
        return 1
    fi
    _koopa_is_alias 'vim' && unalias 'vim'
    "$vim" -u "$vimrc" "$@"
    return 0
}
