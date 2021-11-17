#!/usr/bin/env bash

# FIXME Need to finish consolidation of wrappers here.
# FIXME Consider improving error messages when user attempts to redefine
# an internally defined value (e.g. '--version' when not allowed).

koopa::install_anaconda() { # {{{1
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

# FIXME Consider adding support for pcre here.
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

koopa::install_htop() { # {{{1
    koopa:::install_app \
        --name='htop' \
        "$@"
}

koopa::install_julia() { # {{{1
    if koopa::is_linux
    then
        koopa:::install_app \
            --installer="julia-binary" \
            --name-fancy='Julia' \
            --name='julia' \
            --platform='linux' \
            "$@"
    else
        koopa:::install_app \
            --name-fancy='Julia' \
            --name='julia' \
            "$@"
    fi
    koopa::configure_julia
    return 0
}

koopa::install_julia_packages() { # {{{1
    koopa:::install_app_packages \
        --name-fancy='Julia' \
        --name='julia' \
        "$@"
}

koopa::install_libevent() { # {{{1
    koopa:::install_app \
        --name='libevent' \
        "$@"
}

koopa::install_libtool() { # {{{1
    koopa:::install_gnu_app \
        --name='libtool' \
        "$@"
}

koopa::install_lua() { # {{{1
    koopa:::install_app \
        --name-fancy='Lua' \
        --name='lua' \
        "$@"
}

koopa::install_luarocks() { # {{{1
    koopa:::install_app \
        --name='luarocks' \
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

koopa::install_neofetch() { # {{{1
    koopa:::install_app \
        --name='neofetch' \
        "$@"
}

koopa::install_neovim() { # {{{1
    koopa:::install_app \
        --name='neovim' \
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

koopa::install_nim_packages() { # {{{1
    koopa:::install_app_packages \
        --name-fancy='Nim' \
        --name='nim' \
        "$@"
}

koopa::install_node_packages() { # {{{1
    koopa:::install_app_packages \
        --name-fancy='Node' \
        --name='node' \
        "$@"
}

koopa::install_openjdk() { # {{{1
    koopa:::install_app \
        --name-fancy='OpenJDK' \
        --name='openjdk' \
        --no-link \
        "$@"
}

koopa::install_openssh() { # {{{1
    koopa:::install_app \
        --name-fancy='OpenSSH' \
        --name='openssh' \
        --no-link \
        "$@"
}

koopa::install_openssl() { # {{{1
    koopa:::install_app \
        --name-fancy='OpenSSL' \
        --name='openssl' \
        --no-link \
        "$@"
}

koopa::install_parallel() { # {{{1
    koopa:::install_gnu_app \
        --name='parallel' \
        "$@"
}

koopa::install_password_store() { # {{{1
    koopa:::install_app \
        --name='password-store' \
        "$@"
}

koopa::install_patch() { # {{{1
    koopa:::install_gnu_app \
        --name='patch' \
        "$@"
}

koopa::install_perl() { # {{{1
    koopa:::install_app \
        --name-fancy='Perl' \
        --name='perl' \
        "$@"
    koopa::configure_perl
    return 0
}

koopa::install_perl_packages() { # {{{1
    koopa:::install_app_packages \
        --name-fancy='Perl' \
        --name='perl' \
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
