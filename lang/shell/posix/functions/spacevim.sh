#!/bin/sh

koopa_spacevim() {
    # """
    # SpaceVim alias.
    # @note Updated 2023-01-06.
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
    if [ ! -d "$prefix" ]
    then
        koopa_print "SpaceVim is not installed at '${prefix}'."
        return 1
    fi
    vimrc="${prefix}/vimrc"
    if [ ! -f "$vimrc" ]
    then
        koopa_print "No vimrc file at '${vimrc}'."
        return 1
    fi
    koopa_is_alias 'vim' && unalias 'vim'
    "$vim" -u "$vimrc" "$@"
}
