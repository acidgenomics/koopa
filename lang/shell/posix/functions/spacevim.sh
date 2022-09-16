#!/bin/sh

koopa_spacevim() {
    # """
    # SpaceVim alias.
    # @note Updated 2022-09-16.
    # """
    local gvim prefix vim vimrc
    vim='vim'
    if koopa_is_macos
    then
        gvim='/Applications/MacVim.app/Contents/bin/gvim'
        if [ -x "$gvim" ]
        then
            vim="$gvim"
        fi
    fi
    prefix="$(koopa_spacevim_prefix)"
    vimrc="${prefix}/vimrc"
    [ -f "$vimrc" ] || return 1
    koopa_is_alias 'vim' && unalias 'vim'
    "$vim" -u "$vimrc" "$@"
}
