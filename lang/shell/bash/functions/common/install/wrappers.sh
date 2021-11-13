#!/usr/bin/env bash

koopa::install_anaconda() { # {{{1
    # """
    # Install Anaconda.
    # @note Updated 2021-06-07.
    # """
    koopa:::install_app \
        --name-fancy='Anaconda' \
        --name='anaconda' \
        --no-link \
        "$@"
}

koopa::install_bash() { # {{{1
    koopa:::install_app \
        --name-fancy='Bash' \
        --name='bash' \
        "$@"
}

koopa::install_cmake() { # {{{1
    koopa:::install_app \
        --name='cmake' \
        --name-fancy='CMake' \
        "$@"
}

koopa::install_conda() { # {{{1
    koopa::install_miniconda "$@"
}

koopa::install_doom_emacs() { # {{{1
    koopa:::install_app \
        --name-fancy='Doom Emacs' \
        --name='doom-emacs' \
        --no-shared \
        --prefix="$(koopa::doom_emacs_prefix)" \
        --version='rolling' \
        "$@"
}

koopa::install_miniconda() { # {{{1
    koopa:::install_app \
        --installer='miniconda' \
        --name-fancy='Miniconda' \
        --name='conda' \
        --no-link \
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

koopa::install_tex_packages() { # {{{1
    koopa:::install_app \
        --name-fancy='TeX packages' \
        --name='tex-packages' \
        --system \
        --version='rolling' \
        "$@"
}

koopa::uninstall_anaconda() { # {{{1
    koopa:::uninstall_app \
        --name-fancy='Anaconda' \
        --name='anaconda' \
        --no-link \
        "$@"
}

koopa::uninstall_bash() { # {{{1
    koopa:::uninstall_app \
        --name-fancy='Bash' \
        --name='bash' \
        "$@"
}

koopa::install_chemacs() { # {{{1
    koopa:::install_app \
        --name-fancy='Chemacs' \
        --name='chemacs' \
        --version='rolling' \
        "$@"
}

koopa::uninstall_chemacs() { # {{{1
    # """
    # Uninstall Chemacs2.
    # @note Updated 2021-06-07.
    # """
    koopa:::uninstall_app \
        --name-fancy='Chemacs' \
        --name='chemacs' \
        "$@"
}

koopa::uninstall_cmake() { # {{{1
    koopa:::uninstall_app \
        --name-fancy='CMake' \
        --name='cmake' \
        "$@"
    return 0
}

koopa::uninstall_conda() { # {{{1
    koopa:::uninstall_miniconda "$@"
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

koopa::uninstall_miniconda() { # {{{1
    koopa:::uninstall_app \
        --name-fancy='Miniconda' \
        --name='conda' \
        --no-link \
        --uninstaller='miniconda' \
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

koopa::update_chemacs() { # {{{1
    koopa:::update_app \
        --name='chemacs' \
        --name-fancy='Chemacs' \
        "$@"
}

koopa::update_tex_packages() { # {{{1
    koopa:::update_app \
        --name-fancy='TeX packages' \
        --name='tex-packages' \
        --system \
        "$@"
}
