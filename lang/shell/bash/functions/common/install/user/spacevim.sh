#!/usr/bin/env bash

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

# FIXME Need to wrap this.
koopa::update_spacevim() { # {{{1
    # """
    # Update SpaceVim.
    # @note Updated 2021-06-07.
    # """
    local name_fancy prefix
    koopa::assert_has_no_args "$#"
    koopa::assert_is_installed 'emacs'
    name_fancy='SpaceVim'
    koopa::update_start "$name_fancy"
    prefix="$(koopa::spacevim_prefix)"
    (
        koopa::cd "$prefix"
        koopa::git_pull
    )
    koopa::update_success "$name_fancy"
    return 0
}
