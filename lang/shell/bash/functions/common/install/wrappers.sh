#!/usr/bin/env bash

koopa::install_doom_emacs() { # {{{1
    koopa:::install_app \
        --name-fancy='Doom Emacs' \
        --name='doom-emacs' \
        --no-shared \
        --prefix="$(koopa::doom_emacs_prefix)" \
        --version='rolling' \
        "$@"
}

koopa::install_prelude_emacs() { # {{{1
    koopa:::install_app \
        --name-fancy='Prelude Emacs' \
        --name='prelude-emacs' \
        --no-shared \
        --prefix="$(koopa::prelude_emacs_prefix)" \
        --version='rolling' \
        "$@"
}

koopa::install_spacemacs() { # {{{1
    koopa:::install_app \
        --name-fancy='Spacemacs' \
        --name='spacemacs' \
        --prefix="$(koopa::spacemacs_prefix)" \
        --version='rolling' \
        --no-shared \
        "$@"
}

koopa::install_spacevim() { # {{{1
    koopa:::install_app \
        --name-fancy='SpaceVim' \
        --name='spacevim' \
        --prefix="$(koopa::spacevim_prefix)" \
        --version='rolling' \
        --no-shared \
        "$@"
}

koopa::uninstall_doom_emacs() { # {{{1
    # """
    # Uninstall Doom Emacs.
    # @note Updated 2021-06-08.
    # """
    koopa:::uninstall_app \
        --name-fancy='Doom Emacs' \
        --name='doom-emacs' \
        --no-shared \
        --prefix="$(koopa::doom_emacs_prefix)" \
        "$@"
}

koopa::uninstall_prelude_emacs() { # {{{1
    # """
    # Uninstall Prelude Emacs.
    # @note Updated 2021-06-08.
    # """
    koopa:::uninstall_app \
        --name-fancy='Prelude Emacs' \
        --name='prelude-emacs' \
        --no-shared \
        --prefix="$(koopa::prelude_emacs_prefix)" \
        "$@"
}

koopa::uninstall_spacemacs() { # {{{1
    # """
    # Uninstall Spacemacs.
    # @note Updated 2021-06-08.
    # """
    koopa:::uninstall_app \
        --name-fancy='Spacemacs' \
        --name='spacemacs' \
        --no-shared \
        --prefix="$(koopa::spacemacs_prefix)" \
        "$@"
}

koopa::uninstall_spacevim() { # {{{1
    # """
    # Uninstall SpaceVim.
    # @note Updated 2021-06-11.
    # """
    koopa:::uninstall_app \
        --name-fancy='SpaceVim' \
        --name='spacevim' \
        --no-shared \
        --prefix="$(koopa::spacevim_prefix)" \
        "$@"
}
