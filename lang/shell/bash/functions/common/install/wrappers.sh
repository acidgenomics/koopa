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

koopa::install_cpufetch() { # {{{1
    koopa:::install_app \
        --name='cpufetch' \
        "$@"
}

koopa::install_curl() { # {{{1
    koopa:::install_app \
        --name-fancy='cURL' \
        --name='curl' \
        "$@"
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

# FIXME Need to harden the installer against user input of version here.
koopa::install_ensembl_perl_api() { # {{{1
    koopa:::install_app \
        --name-fancy='Ensembl Perl API' \
        --name='ensembl-perl-api' \
        --no-link \
        --version='rolling' \
        "$@"
}

koopa::install_fish() { # {{{1
    koopa:::install_app \
        --name-fancy='Fish' \
        --name='fish' \
        "$@"
}

koopa::install_fzf() { # {{{1
    koopa:::install_app \
        --name-fancy='FZF' \
        --name='fzf' \
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

koopa::uninstall_cpufetch() { # {{{1
    koopa:::uninstall_app \
        --name='cpufetch' \
        "$@"
}

koopa::uninstall_curl() { # {{{1
    koopa:::uninstall_app \
        --name-fancy='cURL' \
        --name='curl' \
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

# FIXME Rethink the additional per-user configuration step here?
koopa::install_dotfiles() { # {{{1
    local prefix script
    koopa:::install_app \
        --name='dotfiles' \
        --version='rolling' \
        "$@"
    prefix="$(koopa::dotfiles_prefix)"
    koopa::assert_is_dir "$prefix"
    koopa::add_koopa_config_link "$prefix" 'dotfiles'
    script="${prefix}/install"
    koopa::assert_is_file "$script"
    "$script"
    return 0
}

koopa::uninstall_emacs() { # {{{1
    koopa:::uninstall_app \
        --name-fancy='Emacs' \
        --name='emacs' \
        "$@"
}

koopa::uninstall_ensembl_perl_api() { # {{{1
    koopa:::uninstall_app \
        --name-fancy='Ensembl Perl API' \
        --name='ensembl-perl-api' \
        --no-link \
        "$@"
}

koopa::uninstall_fish() { # {{{1
    koopa:::uninstall_app \
        --name-fancy='Fish' \
        --name='fish' \
        "$@"
}

koopa::uninstall_fzf() { # {{{1
    koopa:::uninstall_app \
        --name-fancy='FZF' \
        --name='fzf' \
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
