#!/usr/bin/env bash

# FIXME Need to use app and dict approach here.
koopa:::install_spacevim() { # {{{1
    # """
    # Install SpaceVim.
    # @note Updated 2021-06-17.
    # @seealso
    # - https://spacevim.org
    # - https://spacevim.org/quick-start-guide/
    # - https://spacevim.org/faq/
    # """
    local make prefix vimproc_prefix xdg_data_home
    prefix="${INSTALL_PREFIX:?}"
    repo='https://github.com/SpaceVim/SpaceVim.git'
    make="$(koopa::locate_make)"
    xdg_data_home="$(koopa::xdg_data_home)"
    # Symlink the font cache, to avoid unnecessary copy step.
    koopa::ln "${HOME:?}/Library/Fonts" "${xdg_data_home}/fonts"
    koopa::git_clone "$repo" "$prefix"
    # Bug fix for vimproc error.
    # https://github.com/SpaceVim/SpaceVim/issues/435
    vimproc_prefix="${prefix}/bundle/vimproc.vim"
    koopa::alert "Fixing vimproc at '${vimproc_prefix}'."
    (
        koopa::cd "$vimproc_prefix"
        "$make"
    )
    return 0
}
