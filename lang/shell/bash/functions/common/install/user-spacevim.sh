#!/usr/bin/env bash

# NOTE '--reinstall' is not currently supported.

koopa::install_spacevim() { # {{{1
    # """
    # Install SpaceVim.
    # @note Updated 2021-05-26.
    # https://spacevim.org
    # """
    local name name_fancy prefix script_file script_url tmp_dir
    local vimproc_prefix xdg_data_home
    name='spacevim'
    name_fancy='SpaceVim'
    prefix="$(koopa::spacevim_prefix)"
    xdg_data_home="$(koopa::xdg_data_home)"
    if [[ -d "$prefix" ]]
    then
        koopa::alert_note "${name_fancy} is already installed at '${prefix}'."
        return 0
    fi
    koopa::install_start "$name_fancy"
    # Symlink the font cache, to avoid unnecessary copy step.
    koopa::rm "${xdg_data_home}/fonts"
    koopa::ln "${HOME:?}/Library/Fonts" "${xdg_data_home}/fonts"
    tmp_dir="$(koopa::tmp_dir)"
    (
        koopa::cd "$tmp_dir"
        script_url="https://${name}.org/install.sh"
        script_file="$(koopa::basename "$script_url")"
        koopa::download "$script_url" "$script_file"
        koopa::chmod +x "$script_file"
        "./${script_file}"
    )
    # Bug fix for vimproc error.
    # https://github.com/SpaceVim/SpaceVim/issues/435
    vimproc_prefix="${prefix}/bundle/vimproc.vim"
    koopa::alert "Fixing vimproc at '${vimproc_prefix}'."
    (
        koopa::cd "$vimproc_prefix"
        make
    )
    koopa::install_success "$name_fancy"
    return 0
}

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
        koopa::alert_not_installed "$name_fancy" "$prefix"
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
