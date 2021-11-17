#!/usr/bin/env bash

# FIXME Need to finish consolidation of wrappers here.

koopa::configure_go() { # {{{1
    # """
    # Configure Go.
    # @note Updated 2021-09-17.
    # """
    koopa:::configure_app_packages \
        --name-fancy='Go' \
        --name='go' \
        --which-app="$(koopa::locate_go)" \
        "$@"
}

koopa::configure_nim() { # {{{1
    # """
    # Configure Nim.
    # @note Updated 2021-11-16.
    # """
    koopa:::configure_app_packages \
        --name-fancy='Nim' \
        --name='nim' \
        --which-app="$(koopa::locate_nim)"
    return 0
}

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

koopa::install_autoconf() { # {{{1
    local conf_args
    conf_args=(
        '--name=autoconf'
    )
    # m4 is required for automake to build.
    if koopa::is_macos
    then
        conf_args+=(
            '--homebrew-opt=m4'
        )
    fi
    koopa:::install_gnu_app "${conf_args[@]}" "$@"
}

koopa::install_automake() { # {{{1
    local conf_args
    conf_args=(
        '--name=automake'
        '--opt=autoconf'
    )
    koopa:::install_gnu_app "${conf_args[@]}" "$@"
}

koopa::install_bash() { # {{{1
    koopa:::install_app \
        --name-fancy='Bash' \
        --name='bash' \
        "$@"
}

koopa::install_binutils() { # {{{1
    koopa:::install_gnu_app \
        --name='binutils' \
        "$@"
}

koopa::install_chemacs() { # {{{1
    koopa:::install_app \
        --name-fancy='Chemacs' \
        --name='chemacs' \
        --version='rolling' \
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

koopa::install_coreutils() { # {{{1
    koopa:::install_gnu_app \
        --name='coreutils' \
        "$@"
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

koopa::install_dotfiles() { # {{{1
    local dict
    declare -A dict=(
        [name]='dotfiles'
        [prefix]="$(koopa::dotfiles_prefix)"
        [version]='rolling'
    )
    dict[script]="${dict[prefix]}/install"
    koopa:::install_app \
        --name="${dict[name]}" \
        --version="${dict[version]}" \
        "$@"
    koopa::assert_is_dir "${dict[prefix]}"
    koopa::add_koopa_config_link "${dict[prefix]}" "${dict[name]}"
    koopa::assert_is_file "${dict[script]}"
    "${dict[script]}"
    return 0
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

koopa::install_findutils() { # {{{1
    if koopa::is_macos
    then
        # Workaround for build failures in 4.8.0.
        # See also:
        # - https://github.com/Homebrew/homebrew-core/blob/master/
        #     Formula/findutils.rb
        # - https://lists.gnu.org/archive/html/bug-findutils/2021-01/
        #     msg00050.html
        # - https://lists.gnu.org/archive/html/bug-findutils/2021-01/
        #     msg00051.html
        export CFLAGS='-D__nonnull\(params\)='
    fi
    koopa:::install_gnu_app \
        --name='findutils' \
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

koopa::install_gawk() { # {{{1
    koopa:::install_gnu_app \
        --name='gawk' \
        "$@"
}

koopa::install_gcc() { # {{{1
    koopa:::install_app \
        --name-fancy='GCC' \
        --name='gcc' \
        --no-link \
        "$@"
}

koopa::install_gdal() { # {{{1
    koopa:::install_app \
        --name-fancy='GDAL' \
        --name='gdal' \
        --no-link \
        "$@"
}

koopa::install_geos() { # {{{1
    koopa:::install_app \
        --name-fancy='GEOS' \
        --name='geos' \
        --no-link \
        "$@"
}

koopa::install_git() { # {{{1
    koopa:::install_app \
        --name-fancy='Git' \
        --name='git' \
        "$@"
}

koopa::install_gnupg() { # {{{1
    koopa:::install_app \
        --name-fancy='GnuPG suite' \
        --name='gnupg' \
        "$@"
}

koopa::install_go() { # {{{1
    koopa:::install_app \
        --name-fancy='Go' \
        --name='go' \
        --no-link \
        "$@"
    koopa::configure_go
    return 0
}

# NOTE Consider adding support for pcre here.
koopa::install_grep() { # {{{1
    koopa:::install_gnu_app \
        --name='grep' \
        "$@"
}

koopa::install_groff() { # {{{1
    koopa:::install_gnu_app \
        --name='groff' \
        "$@"
}

koopa::install_gsl() { # {{{1
    koopa:::install_gnu_app \
        --name='gsl' \
        --name-fancy='GSL' \
        "$@"
}

koopa::install_haskell_stack() { # {{{1
    koopa:::install_app \
        --name-fancy='Haskell Stack' \
        --name='haskell-stack' \
        --no-link \
        --version='rolling' \
        "$@"
}

koopa::install_hdf5() { # {{{1
    koopa:::install_app \
        --name-fancy='HDF5' \
        --name='hdf5' \
        "$@"
}

koopa::install_libtool() { # {{{1
    koopa:::install_gnu_app \
        --name='libtool' \
        "$@"
}

koopa::install_make() { # {{{1
    koopa:::install_gnu_app \
        --name='make' \
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

koopa::install_ncurses() { # {{{1
    koopa:::install_gnu_app \
        --name='ncurses' \
        "$@"
}

koopa::install_nim() { # {{{1
    koopa:::install_app \
        --name='nim' \
        --name-fancy='Nim' \
        --link-include-dirs='bin' \
        "$@"
    koopa::configure_nim
    return 0
}

koopa::install_parallel() { # {{{1
    koopa:::install_gnu_app \
        --name='parallel' \
        "$@"
}

koopa::install_patch() { # {{{1
    koopa:::install_gnu_app \
        --name='patch' \
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

koopa::install_sed() { # {{{1
    koopa:::install_gnu_app \
        --name='sed' \
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

koopa::install_tar() { # {{{1
    koopa:::install_gnu_app \
        --name='tar' \
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

koopa::install_texinfo() { # {{{1
    koopa:::install_gnu_app \
        --name='texinfo' \
        "$@"
}

koopa::uninstall_anaconda() { # {{{1
    koopa:::uninstall_app \
        --name-fancy='Anaconda' \
        --name='anaconda' \
        --no-link \
        "$@"
}

koopa::uninstall_autoconf() { # {{{1
    koopa:::uninstall_app \
        --name='autoconf' \
        "$@"
}

koopa::uninstall_automake() { # {{{1
    koopa:::uninstall_app \
        --name='automake' \
        "$@"
}

koopa::uninstall_bash() { # {{{1
    koopa:::uninstall_app \
        --name-fancy='Bash' \
        --name='bash' \
        "$@"
}

koopa::uninstall_binutils() { # {{{1
    koopa:::uninstall_app \
        --name='binutils' \
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

koopa::uninstall_coreutils() { # {{{1
    koopa:::uninstall_app \
        --name='coreutils' \
        "$@"
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

koopa::uninstall_findutils() { # {{{1
    koopa:::uninstall_app \
        --name='findutils' \
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

koopa::uninstall_gawk() { # {{{1
    koopa:::uninstall_app \
        --name='gawk' \
        "$@"
}

koopa::uninstall_gcc() { # {{{1
    koopa:::uninstall_app \
        --name-fancy='GCC' \
        --name='gcc' \
        --no-link \
        "$@"
}

koopa::uninstall_gdal() { # {{{1
    koopa:::uninstall_app \
        --name-fancy='GDAL' \
        --name='gdal' \
        --no-link \
        "$@"
}

koopa::uninstall_geos() { # {{{1
    koopa:::uninstall_app \
        --name-fancy='GEOS' \
        --name='geos' \
        --no-link \
        "$@"
}

koopa::uninstall_git() { # {{{1
    koopa:::uninstall_app \
        --name-fancy='Git' \
        --name='git' \
        "$@"
}

# FIXME Need to use dict approach here.
koopa::uninstall_gnupg() { # {{{1
    local name_fancy
    koopa::assert_has_no_args "$#"
    name_fancy='GnuPG suite'
    koopa::uninstall_start "$name_fancy"
    koopa:::uninstall_app --name='gnupg'
    koopa:::uninstall_app --name='libassuan'
    koopa:::uninstall_app --name='libgcrypt'
    koopa:::uninstall_app --name='libgpg-error'
    koopa:::uninstall_app --name='libksba'
    koopa:::uninstall_app --name='npth'
    koopa::uninstall_success "$name_fancy"
    return 0
}

koopa::uninstall_go() { # {{{1
    koopa:::uninstall_app \
        --name-fancy='Go' \
        --name='go' \
        --no-link \
        "$@"
}

koopa::uninstall_grep() { # {{{1
    koopa:::uninstall_app \
        --name='grep' \
        "$@"
}

koopa::uninstall_groff() { # {{{1
    koopa:::uninstall_app \
        --name='groff' \
        "$@"
}

koopa::uninstall_gsl() { # {{{1
    koopa:::uninstall_app \
        --name='gsl' \
        "$@"
}

koopa::uninstall_haskell_stack() { # {{{1
    koopa:::uninstall_app \
        --name-fancy='Haskell Stack' \
        --name='haskell-stack' \
        --no-link \
        "$@"
}

koopa::uninstall_hdf5() { # {{{1
    koopa:::uninstall_app \
        --name-fancy='HDF5' \
        --name='hdf5' \
        "$@"
}

koopa::uninstall_libtool() { # {{{1
    koopa:::uninstall_app \
        --name='libtool' \
        "$@"
}

koopa::uninstall_make() { # {{{1
    koopa:::uninstall_app \
        --name='make' \
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

koopa::uninstall_ncurses() { # {{{1
    koopa:::uninstall_app \
        --name='ncurses' \
        "$@"
}

koopa::uninstall_nim() { # {{{1
    koopa:::uninstall_app \
        --name-fancy='Nim' \
        --name='nim' \
        "$@"
}

koopa::uninstall_parallel() { # {{{1
    koopa:::uninstall_app \
        --name='parallel' \
        "$@"
}

koopa::uninstall_patch() { # {{{1
    koopa:::uninstall_app \
        --name='patch' \
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

koopa::uninstall_sed() { # {{{1
    koopa:::uninstall_app \
        --name='sed' \
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

koopa::uninstall_tar() { # {{{1
    koopa:::uninstall_app \
        --name='tar' \
        "$@"
}

koopa::uninstall_texinfo() { # {{{1
    koopa:::uninstall_app \
        --name='texinfo' \
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
