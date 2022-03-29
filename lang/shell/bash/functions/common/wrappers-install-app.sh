#!/usr/bin/env bash

koopa_configure_go() { # {{{1
    koopa_configure_app_packages \
        --name-fancy='Go' \
        --name='go' \
        "$@"
}

koopa_configure_julia() { # {{{1
    koopa_configure_app_packages \
        --name-fancy='Julia' \
        --name='julia' \
        "$@"
}

koopa_configure_nim() { # {{{1
    koopa_configure_app_packages \
        --name-fancy='Nim' \
        --name='nim' \
        "$@"
}

koopa_configure_node() { # {{{1
    koopa_configure_app_packages \
        --name-fancy='Node.js' \
        --name='node' \
        "$@"
}

koopa_configure_ruby() { # {{{1
    koopa_configure_app_packages \
        --name-fancy='Ruby' \
        --name='ruby' \
        "$@"
}

koopa_configure_rust() { # {{{1
    koopa_configure_app_packages \
        --name-fancy='Rust' \
        --name='rust' \
        --version='rolling' \
        "$@"
}

koopa_install_anaconda() { # {{{1
    koopa_install_app \
        --name-fancy='Anaconda' \
        --name='anaconda' \
        --no-link \
        "$@"
}

koopa_install_autoconf() { # {{{1
    local install_args
    install_args=('--name=autoconf')
    # m4 is required for automake to build.
    if koopa_is_macos
    then
        install_args+=('--homebrew-opt=m4')
    fi
    koopa_install_gnu_app "${install_args[@]}" "$@"
}

koopa_install_automake() { # {{{1
    koopa_install_gnu_app \
        --name='automake' \
        --opt='autoconf' \
        "$@"
}

koopa_install_bash() { # {{{1
    koopa_install_app \
        --name-fancy='Bash' \
        --name='bash' \
        "$@"
}

koopa_install_binutils() { # {{{1
    koopa_install_gnu_app \
        --name='binutils' \
        "$@"
}

koopa_install_chemacs() { # {{{1
    koopa_install_app \
        --name-fancy='Chemacs' \
        --name='chemacs' \
        --version='rolling' \
        "$@"
}

koopa_install_cmake() { # {{{1
    koopa_install_app \
        --name='cmake' \
        --name-fancy='CMake' \
        "$@"
}

koopa_install_conda() { # {{{1
    koopa_install_app \
        --name-fancy='Miniconda' \
        --name='conda' \
        --no-link \
        "$@"
}

koopa_install_coreutils() { # {{{1
    koopa_install_gnu_app \
        --name='coreutils' \
        "$@"
}

koopa_install_cpufetch() { # {{{1
    koopa_install_app \
        --name='cpufetch' \
        "$@"
}

koopa_install_curl() { # {{{1
    koopa_install_app \
        --name-fancy='cURL' \
        --name='curl' \
        "$@"
}

koopa_install_doom_emacs() { # {{{1
    koopa_install_app \
        --name-fancy='Doom Emacs' \
        --name='doom-emacs' \
        --prefix="$(koopa_doom_emacs_prefix)" \
        --version='rolling' \
        "$@"
}

koopa_install_dotfiles() { # {{{1
    koopa_install_app \
        --name-fancy='Dotfiles' \
        --name='dotfiles' \
        --no-link \
        --version='rolling' \
        "$@"
}

koopa_install_emacs() { # {{{1
    koopa_install_app \
        --name-fancy='Emacs' \
        --name='emacs' \
        "$@"
}

koopa_install_ensembl_perl_api() { # {{{1
    koopa_install_app \
        --name-fancy='Ensembl Perl API' \
        --name='ensembl-perl-api' \
        --no-link \
        --version='rolling' \
        "$@"
}

koopa_install_findutils() { # {{{1
    if koopa_is_macos
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
    koopa_install_gnu_app \
        --name='findutils' \
        "$@"
}

koopa_install_fish() { # {{{1
    koopa_install_app \
        --name-fancy='Fish' \
        --name='fish' \
        "$@"
}

koopa_install_fzf() { # {{{1
    koopa_install_app \
        --name-fancy='FZF' \
        --name='fzf' \
        "$@"
}

koopa_install_gawk() { # {{{1
    koopa_install_gnu_app \
        --name='gawk' \
        "$@"
}

koopa_install_gcc() { # {{{1
    koopa_install_app \
        --name-fancy='GCC' \
        --name='gcc' \
        --no-link \
        "$@"
}

koopa_install_gdal() { # {{{1
    koopa_install_app \
        --name-fancy='GDAL' \
        --name='gdal' \
        --no-link \
        "$@"
}

koopa_install_geos() { # {{{1
    koopa_install_app \
        --name-fancy='GEOS' \
        --name='geos' \
        --no-link \
        "$@"
}

koopa_install_git() { # {{{1
    koopa_install_app \
        --name-fancy='Git' \
        --name='git' \
        "$@"
}

koopa_install_gnu_app() { # {{{1
    koopa_install_app \
        --installer='gnu-app' \
        "$@"
}

koopa_install_gnupg() { # {{{1
    koopa_install_app \
        --name-fancy='GnuPG suite' \
        --name='gnupg' \
        "$@"
}

koopa_install_go() { # {{{1
    koopa_install_app \
        --name-fancy='Go' \
        --name='go' \
        --no-link \
        "$@"
    return 0
}

koopa_install_grep() { # {{{1
    koopa_install_gnu_app \
        --name='grep' \
        "$@"
}

koopa_install_groff() { # {{{1
    koopa_install_gnu_app \
        --name='groff' \
        "$@"
}

koopa_install_gsl() { # {{{1
    koopa_install_gnu_app \
        --name='gsl' \
        --name-fancy='GSL' \
        "$@"
}

koopa_install_haskell_stack() { # {{{1
    koopa_install_app \
        --name-fancy='Haskell Stack' \
        --name='haskell-stack' \
        --no-link \
        --version='rolling' \
        "$@"
}

koopa_install_hdf5() { # {{{1
    koopa_install_app \
        --name-fancy='HDF5' \
        --name='hdf5' \
        "$@"
}

koopa_install_homebrew() { # {{{1
    koopa_install_app \
        --name-fancy='Homebrew' \
        --name='homebrew' \
        --system \
        "$@"
}

koopa_install_homebrew_bundle() { # {{{1
    koopa_install_app \
        --name-fancy='Homebrew bundle' \
        --name='homebrew-bundle' \
        --system \
        "$@"
}

koopa_install_htop() { # {{{1
    koopa_install_app \
        --name='htop' \
        "$@"
}

koopa_install_icu4c() { # {{{1
    koopa_install_app \
        --name-fancy='ICU4C' \
        --name='icu4c' \
        "$@"
}

koopa_install_imagemagick() { # {{{1
    koopa_install_app \
        --name-fancy='ImageMagick' \
        --name='imagemagick' \
        "$@"
}

koopa_install_julia() { # {{{1
    koopa_install_app \
        --name-fancy='Julia' \
        --name='julia' \
        "$@"
}

koopa_install_julia_packages() { # {{{1
    koopa_install_app_packages \
        --name-fancy='Julia' \
        --name='julia' \
        "$@"
}

koopa_install_lesspipe() { # {{{1
    koopa_install_app \
        --name='lesspipe' \
        "$@"
}

koopa_install_libevent() { # {{{1
    koopa_install_app \
        --name='libevent' \
        "$@"
}

koopa_install_libtool() { # {{{1
    koopa_install_gnu_app \
        --name='libtool' \
        "$@"
}

koopa_install_lua() { # {{{1
    koopa_install_app \
        --name-fancy='Lua' \
        --name='lua' \
        "$@"
}

koopa_install_luarocks() { # {{{1
    koopa_install_app \
        --name='luarocks' \
        "$@"
}

koopa_install_make() { # {{{1
    koopa_install_gnu_app \
        --name='make' \
        "$@"
}

koopa_install_mamba() { # {{{1
    koopa_install_app \
        --name-fancy='Mamba' \
        --name='mamba' \
        --system \
        "$@"
}

koopa_install_miniconda() { # {{{1
    koopa_install_conda "$@"
}

koopa_install_ncurses() { # {{{1
    koopa_install_gnu_app \
        --name='ncurses' \
        "$@"
}

koopa_install_neofetch() { # {{{1
    koopa_install_app \
        --name='neofetch' \
        "$@"
}

koopa_install_neovim() { # {{{1
    koopa_install_app \
        --name='neovim' \
        "$@"
}

koopa_install_nim() { # {{{1
    koopa_install_app \
        --link-include='bin' \
        --name-fancy='Nim' \
        --name='nim' \
        "$@"
}

koopa_install_nim_packages() { # {{{1
    koopa_install_app_packages \
        --name-fancy='Nim' \
        --name='nim' \
        "$@"
}

koopa_install_node() { # {{{1
    koopa_install_app \
        --name-fancy='Node.js' \
        --name='node' \
        "$@"
}

koopa_install_node_packages() { # {{{1
    koopa_install_app_packages \
        --name-fancy='Node' \
        --name='node' \
        "$@"
}

koopa_install_openjdk() { # {{{1
    koopa_install_app \
        --name-fancy='OpenJDK' \
        --name='openjdk' \
        --no-link \
        "$@"
}

koopa_install_openssh() { # {{{1
    koopa_install_app \
        --name-fancy='OpenSSH' \
        --name='openssh' \
        --no-link \
        "$@"
}

koopa_install_openssl() { # {{{1
    koopa_install_app \
        --name-fancy='OpenSSL' \
        --name='openssl' \
        --no-link \
        "$@"
}

koopa_install_parallel() { # {{{1
    koopa_install_gnu_app \
        --name='parallel' \
        "$@"
}

koopa_install_password_store() { # {{{1
    koopa_install_app \
        --name='password-store' \
        "$@"
}

koopa_install_patch() { # {{{1
    koopa_install_gnu_app \
        --name='patch' \
        "$@"
}

koopa_install_perl() { # {{{1
    koopa_install_app \
        --name-fancy='Perl' \
        --name='perl' \
        "$@"
}

koopa_install_perl_packages() { # {{{1
    koopa_install_app_packages \
        --name-fancy='Perl' \
        --name='perl' \
        "$@"
}

koopa_install_perlbrew() { # {{{1
    koopa_install_app \
        --name-fancy='Perlbrew' \
        --name='perlbrew' \
        --no-link \
        --version='rolling' \
        "$@"
}

koopa_install_pkg_config() { # {{{1
    koopa_install_app \
        --name='pkg-config' \
        "$@"
}

koopa_install_prelude_emacs() { # {{{1
    koopa_install_app \
        --name-fancy='Prelude Emacs' \
        --name='prelude-emacs' \
        --prefix="$(koopa_prelude_emacs_prefix)" \
        --version='rolling' \
        "$@"
}

koopa_install_proj() { # {{{1
    koopa_install_app \
        --name-fancy='PROJ' \
        --name='proj' \
        --no-link \
        "$@"
}

koopa_install_pyenv() { # {{{1
    koopa_install_app \
        --name='pyenv' \
        --no-link \
        --version='rolling' \
        "$@"
}

koopa_install_python() { # {{{1
    koopa_install_app \
        --name-fancy='Python' \
        --name='python' \
        "$@"
}

koopa_install_python_packages() { # {{{1
    koopa_install_app_packages \
        --name-fancy='Python' \
        --name='python' \
        "$@"
}

koopa_install_r() { # {{{1
    koopa_install_app \
        --name-fancy='R' \
        --name='r' \
        "$@"
}

koopa_install_r_cmd_check() { # {{{1
    koopa_install_app \
        --name-fancy='R CMD check' \
        --name='r-cmd-check' \
        --no-link \
        --version='rolling' \
        "$@"
}

koopa_install_r_koopa() { # {{{1
    koopa_assert_has_no_args "$#"
    koopa_r_koopa 'header'
    return 0
}

koopa_install_r_packages() { # {{{1
    koopa_install_app_packages \
        --name-fancy='R' \
        --name='r' \
        "$@"
}

koopa_install_rbenv() { # {{{1
    koopa_install_app \
        --name='rbenv' \
        --no-link \
        --version='rolling' \
        "$@"
}

koopa_install_rmate() { # {{{1
    koopa_install_app \
        --name='rmate' \
        "$@"
}

koopa_install_rsync() { # {{{1
    koopa_install_app \
        --name='rsync' \
        "$@"
}

koopa_install_ruby() { # {{{1
    koopa_install_app \
        --name-fancy='Ruby' \
        --name='ruby' \
        "$@"
}

koopa_install_ruby_packages() { # {{{1
    koopa_install_app_packages \
        --name-fancy='Ruby' \
        --name='ruby' \
        "$@"
}

koopa_install_rust() { # {{{1
    koopa_install_app \
        --name-fancy='Rust' \
        --name='rust' \
        --no-link \
        --version='rolling' \
        "$@"
}

koopa_install_rust_packages() { # {{{1
    koopa_install_app_packages \
        --name-fancy='Rust' \
        --name='rust' \
        "$@"
}

koopa_install_sed() { # {{{1
    koopa_install_gnu_app \
        --name='sed' \
        "$@"
}

koopa_install_shellcheck() { # {{{1
    koopa_install_app \
        --name-fancy='ShellCheck' \
        --name='shellcheck' \
        "$@"
}

koopa_install_shunit2() { # {{{1
    koopa_install_app \
        --name-fancy='shUnit2' \
        --name='shunit2' \
        "$@"
}

koopa_install_singularity() { # {{{1
    koopa_install_app \
        --name='singularity' \
        "$@"
}

koopa_install_spacemacs() { # {{{1
    koopa_install_app \
        --name-fancy='Spacemacs' \
        --name='spacemacs' \
        --prefix="$(koopa_spacemacs_prefix)" \
        --version='rolling' \
        "$@"
}

koopa_install_spacevim() { # {{{1
    koopa_install_app \
        --name-fancy='SpaceVim' \
        --name='spacevim' \
        --prefix="$(koopa_spacevim_prefix)" \
        --version='rolling' \
        "$@"
}

koopa_install_sqlite() { # {{{1
    koopa_install_app \
        --name-fancy='SQLite' \
        --name='sqlite' \
        "$@"
}

koopa_install_stow() { # {{{1
    koopa_install_gnu_app \
        --name='stow' \
        "$@"
}

koopa_install_subversion() { # {{{1
    koopa_install_app \
        --name='subversion' \
        "$@"
}

koopa_install_taglib() { # {{{1
    koopa_install_app \
        --name-fancy='TagLib' \
        --name='taglib' \
        "$@"
}

koopa_install_tar() { # {{{1
    koopa_install_gnu_app \
        --name='tar' \
        "$@"
}

koopa_install_tex_packages() { # {{{1
    koopa_install_app \
        --name-fancy='TeX packages' \
        --name='tex-packages' \
        --system \
        --version='rolling' \
        "$@"
}

koopa_install_texinfo() { # {{{1
    koopa_install_gnu_app \
        --name='texinfo' \
        "$@"
}

koopa_install_the_silver_searcher() { # {{{1
    koopa_install_app \
        --name='the-silver-searcher' \
        "$@"
}

koopa_install_tmux() { # {{{1
    koopa_install_app \
        --name='tmux' \
        "$@"
}

koopa_install_udunits() { # {{{1
    koopa_install_app \
        --name='udunits' \
        "$@"
}

koopa_install_vim() { # {{{1
    koopa_install_app \
        --name-fancy='Vim' \
        --name='vim' \
        "$@"
}

koopa_install_wget() { # {{{1
    koopa_install_app \
        --name='wget' \
        "$@"
}

koopa_install_zsh() { # {{{1
    koopa_install_app \
        --name-fancy='Zsh' \
        --name='zsh' \
        "$@"
    koopa_fix_zsh_permissions
    return 0
}

koopa_uninstall_anaconda() { # {{{1
    koopa_uninstall_app \
        --name-fancy='Anaconda' \
        --name='anaconda' \
        --no-link \
        "$@"
}

koopa_uninstall_autoconf() { # {{{1
    koopa_uninstall_app \
        --name='autoconf' \
        "$@"
}

koopa_uninstall_automake() { # {{{1
    koopa_uninstall_app \
        --name='automake' \
        "$@"
}

koopa_uninstall_bash() { # {{{1
    koopa_uninstall_app \
        --name-fancy='Bash' \
        --name='bash' \
        "$@"
}

koopa_uninstall_binutils() { # {{{1
    koopa_uninstall_app \
        --name='binutils' \
        "$@"
}

koopa_uninstall_chemacs() { # {{{1
    koopa_uninstall_app \
        --name-fancy='Chemacs' \
        --name='chemacs' \
        "$@"
}

koopa_uninstall_cmake() { # {{{1
    koopa_uninstall_app \
        --name-fancy='CMake' \
        --name='cmake' \
        "$@"
    return 0
}

koopa_uninstall_conda() { # {{{1
    koopa_uninstall_app \
        --name-fancy='Miniconda' \
        --name='conda' \
        --no-link \
        "$@"
}

koopa_uninstall_coreutils() { # {{{1
    koopa_uninstall_app \
        --name='coreutils' \
        "$@"
}

koopa_uninstall_cpufetch() { # {{{1
    koopa_uninstall_app \
        --name='cpufetch' \
        "$@"
}

koopa_uninstall_curl() { # {{{1
    koopa_uninstall_app \
        --name-fancy='cURL' \
        --name='curl' \
        "$@"
}

koopa_uninstall_doom_emacs() { # {{{1
    koopa_uninstall_app \
        --name-fancy='Doom Emacs' \
        --name='doom-emacs' \
        --prefix="$(koopa_doom_emacs_prefix)" \
        "$@"
}

koopa_uninstall_dotfiles() { # {{{1
    # """
    # Uninstall dotfiles.
    # @note Updated 2022-02-15.
    # """
    local app dict
    koopa_assert_has_no_args "$#"
    declare -A app=(
        [bash]="$(koopa_locate_bash)"
    )
    declare -A dict=(
        [name_fancy]='Dotfiles'
        [name]='dotfiles'
        [prefix]="$(koopa_dotfiles_prefix)"
    )
    dict[script]="${dict[prefix]}/uninstall"
    koopa_assert_is_file "${dict[script]}"
    "${app[bash]}" "${dict[script]}"
    koopa_uninstall_app \
        --name-fancy="${dict[name_fancy]}" \
        --name="${dict[name]}" \
        --prefix="${dict[prefix]}" \
        "$@"
    return 0
}

koopa_uninstall_emacs() { # {{{1
    koopa_uninstall_app \
        --name-fancy='Emacs' \
        --name='emacs' \
        "$@"
}

koopa_uninstall_ensembl_perl_api() { # {{{1
    koopa_uninstall_app \
        --name-fancy='Ensembl Perl API' \
        --name='ensembl-perl-api' \
        --no-link \
        "$@"
}

koopa_uninstall_findutils() { # {{{1
    koopa_uninstall_app \
        --name='findutils' \
        "$@"
}

koopa_uninstall_fish() { # {{{1
    koopa_uninstall_app \
        --name-fancy='Fish' \
        --name='fish' \
        "$@"
}

koopa_uninstall_fzf() { # {{{1
    koopa_uninstall_app \
        --name-fancy='FZF' \
        --name='fzf' \
        "$@"
}

koopa_uninstall_gawk() { # {{{1
    koopa_uninstall_app \
        --name='gawk' \
        "$@"
}

koopa_uninstall_gcc() { # {{{1
    koopa_uninstall_app \
        --name-fancy='GCC' \
        --name='gcc' \
        --no-link \
        "$@"
}

koopa_uninstall_gdal() { # {{{1
    koopa_uninstall_app \
        --name-fancy='GDAL' \
        --name='gdal' \
        --no-link \
        "$@"
}

koopa_uninstall_geos() { # {{{1
    koopa_uninstall_app \
        --name-fancy='GEOS' \
        --name='geos' \
        --no-link \
        "$@"
}

koopa_uninstall_git() { # {{{1
    koopa_uninstall_app \
        --name-fancy='Git' \
        --name='git' \
        "$@"
}

koopa_uninstall_gnupg() { # {{{1
    koopa_uninstall_app \
        --name-fancy='GnuPG suite' \
        --name='gnupg' \
        "$@"
}

koopa_uninstall_go() { # {{{1
    koopa_uninstall_app \
        --name-fancy='Go' \
        --name='go' \
        --no-link \
        "$@"
}

koopa_uninstall_grep() { # {{{1
    koopa_uninstall_app \
        --name='grep' \
        "$@"
}

koopa_uninstall_groff() { # {{{1
    koopa_uninstall_app \
        --name='groff' \
        "$@"
}

koopa_uninstall_gsl() { # {{{1
    koopa_uninstall_app \
        --name='gsl' \
        "$@"
}

koopa_uninstall_haskell_stack() { # {{{1
    koopa_uninstall_app \
        --name-fancy='Haskell Stack' \
        --name='haskell-stack' \
        --no-link \
        "$@"
}

koopa_uninstall_hdf5() { # {{{1
    koopa_uninstall_app \
        --name-fancy='HDF5' \
        --name='hdf5' \
        "$@"
}

koopa_uninstall_homebrew() { # {{{1
    koopa_uninstall_app \
        --name-fancy='Homebrew' \
        --name='homebrew' \
        --system \
        "$@"
}

koopa_uninstall_htop() { # {{{1
    koopa_uninstall_app \
        --name='htop' \
        "$@"
}

koopa_uninstall_icu4c() { # {{{1
    koopa_uninstall_app \
        --name-fancy='ICU4C' \
        --name='icu4c' \
        "$@"
}

koopa_uninstall_imagemagick() { # {{{1
    koopa_uninstall_app \
        --name-fancy='ImageMagick' \
        --name='imagemagick' \
        "$@"
}

koopa_uninstall_julia() { # {{{1
    koopa_uninstall_app \
        --name-fancy='Julia' \
        --name='julia' \
        "$@"
}

koopa_uninstall_julia_packages() { # {{{1
    koopa_uninstall_app \
        --name-fancy='Julia packages' \
        --name='julia-packages' \
        --no-link \
        "$@"
}

koopa_uninstall_koopa() { # {{{1
    local app
    declare -A app=(
        [bash]="$(koopa_locate_bash)"
    )
    "${app[bash]}" "$(koopa_koopa_prefix)/uninstall" "$@"
    return 0
}

koopa_uninstall_lesspipe() { # {{{1
    koopa_uninstall_app \
        --name='lesspipe' \
        "$@"
}

koopa_uninstall_libevent() { # {{{1
    koopa_uninstall_app \
        --name='libevent' \
        "$@"
}

koopa_uninstall_libtool() { # {{{1
    koopa_uninstall_app \
        --name='libtool' \
        "$@"
}

koopa_uninstall_lua() { # {{{1
    koopa_uninstall_app \
        --name-fancy='Lua' \
        --name='lua' \
        "$@"
}

koopa_uninstall_luarocks() { # {{{1
    koopa_uninstall_app \
        --name='luarocks' \
        "$@"
}

koopa_uninstall_make() { # {{{1
    koopa_uninstall_app \
        --name='make' \
        "$@"
}

koopa_uninstall_miniconda() { # {{{1
    koopa_uninstall_conda "$@"
}

koopa_uninstall_ncurses() { # {{{1
    koopa_uninstall_app \
        --name='ncurses' \
        "$@"
}

koopa_uninstall_neofetch() { # {{{1
    koopa_uninstall_app \
        --name='neofetch' \
        "$@"
}

koopa_uninstall_neovim() { # {{{1
    koopa_uninstall_app \
        --name='neovim' \
        "$@"
}

koopa_uninstall_nim() { # {{{1
    koopa_uninstall_app \
        --name-fancy='Nim' \
        --name='nim' \
        "$@"
}

koopa_uninstall_nim_packages() { # {{{1
    koopa_uninstall_app \
        --name='nim-packages' \
        --name-fancy='Nim packages' \
        --no-link \
        "$@"
}

koopa_uninstall_node() { # {{{1
    koopa_uninstall_app \
        --name-fancy='Node.js' \
        --name='node' \
        "$@"
}

koopa_uninstall_node_packages() { # {{{1
    koopa_uninstall_app \
        --name='node-packages' \
        --name-fancy='Node.js packages' \
        --no-link \
        "$@"
}

koopa_uninstall_openjdk() { # {{{1
    local dict
    declare -A dict
    koopa_uninstall_app \
        --name-fancy='OpenJDK' \
        --name='openjdk' \
        --no-link \
        "$@"
    if koopa_is_linux
    then
        dict[default_java]='/usr/lib/jvm/default-java'
        if [[ -d "${dict[default_java]}" ]]
        then
            koopa_linux_java_update_alternatives "${dict[default_java]}"
        fi
    fi
    return 0
}

koopa_uninstall_openssh() { # {{{1
    koopa_uninstall_app \
        --name-fancy='OpenSSH' \
        --name='openssh' \
        --no-link \
        "$@"
}

koopa_uninstall_openssl() { # {{{1
    koopa_uninstall_app \
        --name-fancy='OpenSSL' \
        --name='openssl' \
        --no-link \
        "$@"
}

koopa_uninstall_parallel() { # {{{1
    koopa_uninstall_app \
        --name='parallel' \
        "$@"
}

koopa_uninstall_password_store() { # {{{1
    koopa_uninstall_app \
        --name='password-store' \
        "$@"
}

koopa_uninstall_patch() { # {{{1
    koopa_uninstall_app \
        --name='patch' \
        "$@"
}

koopa_uninstall_perl() { # {{{1
    koopa_uninstall_app \
        --name-fancy='Perl' \
        --name='perl' \
        "$@"
}

koopa_uninstall_perl_packages() { # {{{1
    koopa_uninstall_app \
        --name-fancy='Perl packages' \
        --name='perl-packages' \
        "$@"
    koopa_rm "${HOME:?}/.cpan" "${HOME:?}/.cpanm"
    return 0
}

koopa_uninstall_perlbrew() { # {{{1
    koopa_uninstall_app \
        --name-fancy='Perlbrew' \
        --name='perlbrew' \
        --no-link \
        "$@"
}

koopa_uninstall_pkg_config() { # {{{1
    koopa_uninstall_app \
        --name='pkg-config' \
        "$@"
}

koopa_uninstall_prelude_emacs() { # {{{1
    koopa_uninstall_app \
        --name-fancy='Prelude Emacs' \
        --name='prelude-emacs' \
        --prefix="$(koopa_prelude_emacs_prefix)" \
        "$@"
}

koopa_uninstall_proj() { # {{{1
    koopa_uninstall_app \
        --name-fancy='PROJ' \
        --name='proj' \
        --no-link \
        "$@"
}

koopa_uninstall_pyenv() { # {{{1
    koopa_uninstall_app \
        --name='pyenv' \
        --no-link \
        "$@"
}

koopa_uninstall_python() { # {{{1
    koopa_uninstall_app \
        --name-fancy='Python' \
        --name='python' \
        "$@"
}

koopa_uninstall_python_packages() { # {{{1
    koopa_uninstall_app \
        --name-fancy='Python packages' \
        --name='python-packages' \
        --no-link \
        "$@"
}

koopa_uninstall_r() { # {{{1
    koopa_uninstall_app \
        --name-fancy='R' \
        --name='r' \
        "$@"
}

koopa_uninstall_r_cmd_check() { # {{{1
    koopa_uninstall_app \
        --name='r-cmd-check' \
        --no-link \
        "$@"
}

koopa_uninstall_r_packages() { # {{{1
    koopa_uninstall_app \
        --name-fancy='R packages' \
        --name='r-packages' \
        --no-link \
        "$@"
}

koopa_uninstall_rbenv() { # {{{1
    koopa_uninstall_app \
        --name='rbenv' \
        --no-link \
        "$@"
}

koopa_uninstall_rmate() { # {{{1
    koopa_uninstall_app \
        --name='rmate' \
        "$@"
}

koopa_uninstall_rsync() { # {{{1
    koopa_uninstall_app \
        --name='rsync' \
        "$@"
}

koopa_uninstall_ruby() { # {{{1
    koopa_uninstall_app \
        --name-fancy='Ruby' \
        --name='ruby' \
        "$@"
}

koopa_uninstall_ruby_packages() { # {{{1
    koopa_uninstall_app \
        --name-fancy='Ruby packages' \
        --name='ruby-packages' \
        --no-link \
        "$@"
}

koopa_uninstall_rust() { # {{{1
    koopa_uninstall_app \
        --name-fancy='Rust' \
        --name='rust' \
        --no-link \
        "$@"
}

koopa_uninstall_rust_packages() { # {{{1
    koopa_uninstall_app \
        --name-fancy='Rust packages' \
        --name='rust-packages' \
        --no-link \
        "$@"
}

koopa_uninstall_sed() { # {{{1
    koopa_uninstall_app \
        --name='sed' \
        "$@"
}

koopa_uninstall_shellcheck() { # {{{1
    koopa_uninstall_app \
        --name-fancy='ShellCheck' \
        --name='shellcheck' \
        "$@"
}

koopa_uninstall_shunit2() { # {{{1
    koopa_uninstall_app \
        --name-fancy='shUnit2' \
        --name='shunit2' \
        "$@"
}

koopa_uninstall_singularity() { # {{{1
    koopa_uninstall_app \
        --name='singularity' \
        "$@"
}

koopa_uninstall_spacemacs() { # {{{1
    koopa_uninstall_app \
        --name-fancy='Spacemacs' \
        --name='spacemacs' \
        --prefix="$(koopa_spacemacs_prefix)" \
        "$@"
}

koopa_uninstall_spacevim() { # {{{1
    koopa_uninstall_app \
        --name-fancy='SpaceVim' \
        --name='spacevim' \
        --prefix="$(koopa_spacevim_prefix)" \
        "$@"
}

koopa_uninstall_sqlite() { # {{{1
    koopa_uninstall_app \
        --name-fancy='SQLite' \
        --name='sqlite' \
        "$@"
}

koopa_uninstall_stow() { # {{{1
    koopa_uninstall_app \
        --name='stow' \
        "$@"
}

koopa_uninstall_subversion() { # {{{1
    koopa_uninstall_app \
        --name='subversion' \
        "$@"
}

koopa_uninstall_taglib() { # {{{1
    koopa_uninstall_app \
        --name-fancy='TagLib' \
        --name='taglib' \
        "$@"
}

koopa_uninstall_tar() { # {{{1
    koopa_uninstall_app \
        --name='tar' \
        "$@"
}

koopa_uninstall_texinfo() { # {{{1
    koopa_uninstall_app \
        --name='texinfo' \
        "$@"
}

koopa_uninstall_the_silver_searcher() { # {{{1
    koopa_uninstall_app \
        --name='the-silver-searcher' \
        "$@"
}

koopa_uninstall_tmux() { # {{{1
    koopa_uninstall_app \
        --name='tmux' \
        "$@"
}

koopa_uninstall_udunits() { # {{{1
    koopa_uninstall_app \
        --name='udunits' \
        "$@"
}

koopa_uninstall_vim() { # {{{1
    koopa_uninstall_app \
        --name-fancy='Vim' \
        --name='vim' \
        "$@"
}

koopa_uninstall_wget() { # {{{1
    koopa_uninstall_app \
        --name='wget' \
        "$@"
}

koopa_uninstall_zsh() { # {{{1
    koopa_uninstall_app \
        --name-fancy="Zsh" \
        --name='zsh' \
        "$@"
}

koopa_update_chemacs() { # {{{1
    koopa_update_app \
        --name='chemacs' \
        --name-fancy='Chemacs' \
        "$@"
}

koopa_update_doom_emacs() { # {{{1
    koopa_update_app \
        --name-fancy='Doom Emacs' \
        --name='doom-emacs' \
        --prefix="$(koopa_doom_emacs_prefix)" \
        "$@"
}

koopa_update_dotfiles() { # {{{1
    koopa_update_app \
        --name='dotfiles' \
        --name-fancy='Dotfiles' \
        "$@"
}

koopa_update_homebrew() { # {{{1
    koopa_update_app \
        --name='homebrew' \
        --name-fancy='Homebrew' \
        --system \
        "$@"
}

koopa_update_julia_packages() { # {{{1
    koopa_install_julia_packages "$@"
}

koopa_update_koopa() { # {{{1
    koopa_update_app \
        --name='koopa' \
        --prefix="$(koopa_koopa_prefix)" \
        --system \
        "$@"
}

koopa_update_mamba() { # {{{1
    koopa_install_mamba "$@"
}

koopa_update_nim_packages() { # {{{1
    koopa_install_nim_packages "$@"
}

koopa_update_node_packages() { # {{{1
    koopa_install_node_packages "$@"
}

koopa_update_perl_packages() { # {{{1
    koopa_install_perl_packages "$@"
}

koopa_update_perlbrew() { # {{{1
    koopa_update_app \
        --name='perlbrew' \
        --name-fancy='Perlbrew' \
        "$@"
}

koopa_update_prelude_emacs() { # {{{1
    koopa_update_app \
        --name-fancy='Prelude Emacs' \
        --name='prelude-emacs' \
        --prefix="$(koopa_prelude_emacs_prefix)" \
        "$@"
}

koopa_update_pyenv() { # {{{1
    koopa_update_app \
        --name='pyenv' \
        "$@"
}

koopa_update_r_cmd_check() { # {{{1
    koopa_update_app \
        --name='r-cmd-check' \
        --name-fancy='R CMD check' \
        "$@"
}

koopa_update_r_packages() { # {{{1
    koopa_update_app \
        --name-fancy='R packages' \
        --name='r-packages' \
        "$@"
}

koopa_update_rbenv() { # {{{1
    koopa_update_app \
        --name='rbenv' \
        "$@"
}

koopa_update_ruby_packages() {  # {{{1
    koopa_install_ruby_packages "$@"
}

koopa_update_rust() { # {{{1
    koopa_update_app \
        --name-fancy='Rust' \
        --name='rust' \
        "$@"
}

koopa_update_rust_packages() { # {{{1
    koopa_update_app \
        --name-fancy='Rust packages' \
        --name='rust-packages' \
        "$@"
}

koopa_update_spacemacs() { # {{{1
    koopa_update_app \
        --name-fancy='Spacemacs' \
        --name='spacemacs' \
        --prefix="$(koopa_spacemacs_prefix)" \
        "$@"
}

koopa_update_spacevim() { # {{{1
    koopa_update_app \
        --name-fancy='SpaceVim' \
        --name='spacevim' \
        --prefix="$(koopa_spacevim_prefix)" \
        "$@"
}

koopa_update_system() { # {{{1
    koopa_update_app \
        --name='system' \
        --system \
        "$@"
}

koopa_update_tex_packages() { # {{{1
    koopa_update_app \
        --name-fancy='TeX packages' \
        --name='tex-packages' \
        --system \
        "$@"
}
