#!/usr/bin/env bash

koopa::install_spacevim() {
    # """
    # Install SpaceVim.
    # @note Updated 2021-04-20.
    # https://spacevim.org
    # """
    curl -sLf https://spacevim.org/install.sh | bash
    return 0
}

koopa::uninstall_spacevim() { # {{{1
    # """
    # Uninstall SpaceVim.
    # @note Updated 2021-04-20.
    # """
    koopa::rm \
        "${HOME}/.SpaceVim" \
        "${HOME}/.SpaceVim.d" \
        "${HOME}/.cache/SpaceVim"
    return 0
}
