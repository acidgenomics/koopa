#!/usr/bin/env bash

koopa::install_spacevim() {
    # """
    # Install SpaceVim.
    # @note Updated 2021-04-20.
    # https://spacevim.org
    # """
    local name_fancy
    name_fancy="SpaceVim"
    if [[ -d "${HOME}/.SpaceVim" ]]
    then
        koopa::alert_note "${name_fancy} is already installed."
        return 0
    fi
    koopa::install_start "$name_fancy"
    curl -sLf https://spacevim.org/install.sh | bash
    koopa::install_success "$name_fancy"
    return 0
}

koopa::uninstall_spacevim() { # {{{1
    # """
    # Uninstall SpaceVim.
    # @note Updated 2021-04-20.
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
    koopa::uninstall_success "$name_fancy"
    return 0
}
