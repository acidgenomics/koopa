#!/usr/bin/env bash

koopa::uninstall_anaconda() { # {{{1
    koopa::uninstall_app \
        --name-fancy='Anaconda' \
        --name='anaconda' \
        --no-link \
        "$@"
}

koopa::uninstall_autoconf() { # {{{1
    koopa::uninstall_app \
        --name='autoconf' \
        "$@"
}

koopa::uninstall_automake() { # {{{1
    koopa::uninstall_app \
        --name='automake' \
        "$@"
}

koopa::uninstall_bash() { # {{{1
    koopa::uninstall_app \
        --name-fancy='Bash' \
        --name='bash' \
        "$@"
}

koopa::uninstall_binutils() { # {{{1
    koopa::uninstall_app \
        --name='binutils' \
        "$@"
}

koopa::uninstall_chemacs() { # {{{1
    koopa::uninstall_app \
        --name-fancy='Chemacs' \
        --name='chemacs' \
        "$@"
}

koopa::uninstall_cmake() { # {{{1
    koopa::uninstall_app \
        --name-fancy='CMake' \
        --name='cmake' \
        "$@"
    return 0
}

koopa::uninstall_conda() { # {{{1
    koopa:::uninstall_miniconda "$@"
}

koopa::uninstall_coreutils() { # {{{1
    koopa::uninstall_app \
        --name='coreutils' \
        "$@"
}

koopa::uninstall_cpufetch() { # {{{1
    koopa::uninstall_app \
        --name='cpufetch' \
        "$@"
}

koopa::uninstall_curl() { # {{{1
    koopa::uninstall_app \
        --name-fancy='cURL' \
        --name='curl' \
        "$@"
}

koopa::uninstall_doom_emacs() { # {{{1
    koopa::uninstall_app \
        --name-fancy='Doom Emacs' \
        --name='doom-emacs' \
        --no-shared \
        --prefix="$(koopa::doom_emacs_prefix)" \
        "$@"
}

koopa::uninstall_emacs() { # {{{1
    koopa::uninstall_app \
        --name-fancy='Emacs' \
        --name='emacs' \
        "$@"
}

koopa::uninstall_ensembl_perl_api() { # {{{1
    koopa::uninstall_app \
        --name-fancy='Ensembl Perl API' \
        --name='ensembl-perl-api' \
        --no-link \
        "$@"
}

koopa::uninstall_findutils() { # {{{1
    koopa::uninstall_app \
        --name='findutils' \
        "$@"
}

koopa::uninstall_fish() { # {{{1
    koopa::uninstall_app \
        --name-fancy='Fish' \
        --name='fish' \
        "$@"
}

koopa::uninstall_fzf() { # {{{1
    koopa::uninstall_app \
        --name-fancy='FZF' \
        --name='fzf' \
        "$@"
}

koopa::uninstall_gawk() { # {{{1
    koopa::uninstall_app \
        --name='gawk' \
        "$@"
}

koopa::uninstall_gcc() { # {{{1
    koopa::uninstall_app \
        --name-fancy='GCC' \
        --name='gcc' \
        --no-link \
        "$@"
}

koopa::uninstall_gdal() { # {{{1
    koopa::uninstall_app \
        --name-fancy='GDAL' \
        --name='gdal' \
        --no-link \
        "$@"
}

koopa::uninstall_geos() { # {{{1
    koopa::uninstall_app \
        --name-fancy='GEOS' \
        --name='geos' \
        --no-link \
        "$@"
}

koopa::uninstall_git() { # {{{1
    koopa::uninstall_app \
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
    koopa::uninstall_app --name='gnupg'
    koopa::uninstall_app --name='libassuan'
    koopa::uninstall_app --name='libgcrypt'
    koopa::uninstall_app --name='libgpg-error'
    koopa::uninstall_app --name='libksba'
    koopa::uninstall_app --name='npth'
    koopa::uninstall_success "$name_fancy"
    return 0
}

koopa::uninstall_go() { # {{{1
    koopa::uninstall_app \
        --name-fancy='Go' \
        --name='go' \
        --no-link \
        "$@"
}

koopa::uninstall_grep() { # {{{1
    koopa::uninstall_app \
        --name='grep' \
        "$@"
}

koopa::uninstall_groff() { # {{{1
    koopa::uninstall_app \
        --name='groff' \
        "$@"
}

koopa::uninstall_gsl() { # {{{1
    koopa::uninstall_app \
        --name='gsl' \
        "$@"
}

koopa::uninstall_haskell_stack() { # {{{1
    koopa::uninstall_app \
        --name-fancy='Haskell Stack' \
        --name='haskell-stack' \
        --no-link \
        "$@"
}

koopa::uninstall_hdf5() { # {{{1
    koopa::uninstall_app \
        --name-fancy='HDF5' \
        --name='hdf5' \
        "$@"
}

koopa::uninstall_htop() { # {{{1
    koopa::uninstall_app \
        --name='htop' \
        "$@"
}

koopa::uninstall_julia() { # {{{1
    koopa::uninstall_app \
        --name-fancy='Julia' \
        --name='julia' \
        "$@"
}

koopa::uninstall_julia_packages() { # {{{1
    koopa::uninstall_app \
        --name-fancy='Julia packages' \
        --name='julia-packages' \
        --no-link \
        "$@"
}

koopa::uninstall_koopa() { # {{{1
    # """
    # Uninstall koopa.
    # @note Updated 2020-06-24.
    # """
    "$(koopa::koopa_prefix)/uninstall" "$@"
    return 0
}

koopa::uninstall_libevent() { # {{{1
    koopa::uninstall_app \
        --name='libevent' \
        "$@"
}

koopa::uninstall_libtool() { # {{{1
    koopa::uninstall_app \
        --name='libtool' \
        "$@"
}

koopa::uninstall_lua() { # {{{1
    koopa::uninstall_app \
        --name-fancy='Lua' \
        --name='lua' \
        "$@"
}

koopa::uninstall_luarocks() { # {{{1
    koopa::uninstall_app \
        --name='luarocks' \
        "$@"
}

koopa::uninstall_make() { # {{{1
    koopa::uninstall_app \
        --name='make' \
        "$@"
}

koopa::uninstall_miniconda() { # {{{1
    koopa::uninstall_app \
        --name-fancy='Miniconda' \
        --name='conda' \
        --no-link \
        --uninstaller='miniconda' \
        "$@"
}

koopa::uninstall_ncurses() { # {{{1
    koopa::uninstall_app \
        --name='ncurses' \
        "$@"
}

koopa::uninstall_neofetch() { # {{{1
    koopa::uninstall_app \
        --name='neofetch' \
        "$@"
}

koopa::uninstall_neovim() { # {{{1
    koopa::uninstall_app \
        --name='neovim' \
        "$@"
}

koopa::uninstall_nim() { # {{{1
    koopa::uninstall_app \
        --name-fancy='Nim' \
        --name='nim' \
        "$@"
}

koopa::uninstall_nim_packages() { # {{{1
    koopa::uninstall_app \
        --name='nim-packages' \
        --name-fancy='Nim packages' \
        --no-link \
        "$@"
}

koopa::uninstall_node_packages() { # {{{1
    koopa::uninstall_app \
        --name='node-packages' \
        --name-fancy='Node.js packages' \
        --no-link \
        "$@"
}

koopa::uninstall_openjdk() { # {{{1
    local default_prefix
    koopa::uninstall_app \
        --name-fancy='OpenJDK' \
        --name='openjdk' \
        --no-link \
        "$@"
    if koopa::is_linux
    then
        default_prefix='/usr/lib/jvm/default-java'
        if [[ -d "$default_prefix" ]]
        then
            koopa::linux_java_update_alternatives "$default_prefix"
        fi
    fi
    return 0
}

koopa::uninstall_openssh() { # {{{1
    koopa::uninstall_app \
        --name-fancy='OpenSSH' \
        --name='openssh' \
        --no-link \
        "$@"
}

koopa::uninstall_openssl() { # {{{1
    koopa::uninstall_app \
        --name-fancy='OpenSSL' \
        --name='openssl' \
        --no-link \
        "$@"
}

koopa::uninstall_parallel() { # {{{1
    koopa::uninstall_app \
        --name='parallel' \
        "$@"
}

koopa::uninstall_password_store() { # {{{1
    koopa::uninstall_app \
        --name='password-store' \
        "$@"
}

koopa::uninstall_patch() { # {{{1
    koopa::uninstall_app \
        --name='patch' \
        "$@"
}

koopa::uninstall_perl() { # {{{1
    koopa::uninstall_app \
        --name-fancy='Perl' \
        --name='perl' \
        "$@"
}

koopa::uninstall_perl_packages() { # {{{1
    koopa::uninstall_app \
        --name-fancy='Perl packages' \
        --name='perl-packages' \
        "$@"
}

koopa::uninstall_prelude_emacs() { # {{{1
    koopa::uninstall_app \
        --name-fancy='Prelude Emacs' \
        --name='prelude-emacs' \
        --no-shared \
        --prefix="$(koopa::prelude_emacs_prefix)" \
        "$@"
}

koopa::uninstall_python_packages() { # {{{1
    # """
    # Uninstall Python packages.
    # @note Updated 2021-06-14.
    # """
    koopa::uninstall_app \
        --name-fancy='Python packages' \
        --name='python-packages' \
        --no-link \
        "$@"
}

koopa::uninstall_rust_packages() { # {{{1
    koopa::uninstall_app \
        --name-fancy='Rust packages' \
        --name='rust-packages' \
        --no-link \
        "$@"
}

koopa::uninstall_sed() { # {{{1
    koopa::uninstall_app \
        --name='sed' \
        "$@"
}

koopa::uninstall_spacemacs() { # {{{1
    koopa::uninstall_app \
        --name-fancy='Spacemacs' \
        --name='spacemacs' \
        --no-shared \
        --prefix="$(koopa::spacemacs_prefix)" \
        "$@"
}

koopa::uninstall_spacevim() { # {{{1
    koopa::uninstall_app \
        --name-fancy='SpaceVim' \
        --name='spacevim' \
        --no-shared \
        --prefix="$(koopa::spacevim_prefix)" \
        "$@"
}

koopa::uninstall_tar() { # {{{1
    koopa::uninstall_app \
        --name='tar' \
        "$@"
}

koopa::uninstall_texinfo() { # {{{1
    koopa::uninstall_app \
        --name='texinfo' \
        "$@"
}
