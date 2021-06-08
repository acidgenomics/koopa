#!/usr/bin/env bash

# FIXME Need to support an uninstaller.

koopa::install_spacevim() { # {{{1
    koopa::install_app \
        --name-fancy='SpaceVim' \
        --name='spacevim' \
        --prefix="$(koopa::spacevim_prefix)" \
        --version='rolling' \
        --no-shared \
        "$@"
}

koopa:::install_spacevim() { # {{{1
    # """
    # Install SpaceVim.
    # @note Updated 2021-06-07.
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
    # Install script method, which overwrites '~/.vim' and '~/.vimrc'.
    # > local script_file script_url
    # > script_url="https://spacevim.org/install.sh"
    # > script_file="$(koopa::basename "$script_url")"
    # > koopa::download "$script_url" "$script_file"
    # > koopa::chmod +x "$script_file"
    # > "./${script_file}"
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

# FIXME Need to rework this after new approach using Git clone...
koopa::uninstall_spacevim() { # {{{1
    # """
    # Uninstall SpaceVim.
    # @note Updated 2021-05-26.
    # """
    local name_fancy prefix
    name_fancy='SpaceVim'
    prefix="$(koopa::spacevim_prefix)"
    if [[ ! -d "$prefix" ]]
    then
        koopa::alert_is_not_installed "$name_fancy" "$prefix"
        return 0
    fi
    koopa::uninstall_start "$name_fancy"
    koopa::rm \
        "$prefix" \
        "${prefix}.d" \
        "${HOME:?}/.cache/SpaceVim"
    if [[ -d "${HOME:?}/.vim_back" ]]
    then
        koopa::rm "${HOME:?}/.vim"
        koopa::mv "${HOME:?}/.vim_back" "${HOME:?}/.vim"
    fi
    if [[ -f "${HOME:?}/.vimrc_back" ]]
    then
        koopa::rm "${HOME:?}/.vimrc"
        koopa::mv "${HOME:?}/.vimrc_back" "${HOME:?}/.vimrc"
    fi
    koopa::uninstall_success "$name_fancy"
    return 0
}

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
