#!/usr/bin/env bash

koopa::install_spacevim() {
    # """
    # Install SpaceVim.
    # @note Updated 2021-04-21.
    # https://spacevim.org
    # """
    local name_fancy script_file script_url tmp_dir vimproc_prefix
    name_fancy="SpaceVim"
    if [[ -d "${HOME}/.SpaceVim" ]]
    then
        koopa::alert_note "${name_fancy} is already installed."
        return 0
    fi
    koopa::install_start "$name_fancy"
    # Symlink the font cache, to avoid unnecessary copy step.
    koopa::rm "${XDG_DATA_HOME:?}/fonts"
    koopa::ln "${HOME}/Library/Fonts" "${XDG_DATA_HOME:?}/fonts"
    tmp_dir="$(koopa::tmp_dir)"
    (
        koopa::cd "$tmp_dir"
        script_url="https://spacevim.org/install.sh"
        script_file="$(koopa::basename "$script_url")"
        koopa::download "$script_url" "$script_file"
        chmod +x "$script_file"
        "./${script_file}"
    )
    # Bug fix for vimproc error.
    # https://github.com/SpaceVim/SpaceVim/issues/435
    vimproc_prefix="${HOME}/.SpaceVim/bundle/vimproc.vim"
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
    # @note Updated 2021-04-21.
    # """
    local name_fancy
    name_fancy="SpaceVim"
    if [[ ! -d "${HOME}/.SpaceVim" ]]
    then
        koopa::alert_note "${name_fancy} is not installed."
        return 0
    fi
    koopa::uninstall_start "$name_fancy"
    koopa::rm \
        "${HOME}/.SpaceVim" \
        "${HOME}/.SpaceVim.d" \
        "${HOME}/.cache/SpaceVim"
    if [[ -d "${HOME}/.vim_back" ]]
    then
        koopa::rm "${HOME}/.vim"
        koopa::mv "${HOME}/.vim_back" "${HOME}/.vim"
    fi
    if [[ -f "${HOME}/.vimrc_back" ]]
    then
        koopa::rm "${HOME}/.vimrc"
        koopa::mv "${HOME}/.vimrc_back" "${HOME}/.vimrc"
    fi
    koopa::uninstall_success "$name_fancy"
    return 0
}
