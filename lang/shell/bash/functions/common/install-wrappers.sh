#!/usr/bin/env bash

koopa::configure_go() { # {{{1
    koopa::configure_app_packages \
        --name-fancy='Go' \
        --name='go' \
        --which-app="$(koopa::locate_go)" \
        "$@"
}

koopa::configure_julia() { # {{{1
    koopa::configure_app_packages \
        --name-fancy='Julia' \
        --name='julia' \
        --which-app="$(koopa::locate_julia)" \
        "$@"
}

koopa::configure_nim() { # {{{1
    koopa::configure_app_packages \
        --name-fancy='Nim' \
        --name='nim' \
        --which-app="$(koopa::locate_nim)" \
        "$@"
}

koopa::configure_node() { # {{{1
    koopa::configure_app_packages \
        --name-fancy='Node.js' \
        --name='node' \
        --which-app="$(koopa::locate_node)" \
        "$@"
}

koopa::configure_ruby() { # {{{1
    koopa::configure_app_packages \
        --name-fancy='Ruby' \
        --name='ruby' \
        --which-app="$(koopa::locate_ruby)" \
        "$@"
    return 0
}

koopa::configure_rust() { # {{{1
    koopa::configure_app_packages \
        --name-fancy='Rust' \
        --name='rust' \
        --version='rolling' \
        "$@"
}

koopa::install_anaconda() { # {{{1
    koopa::install_app \
        --name-fancy='Anaconda' \
        --name='anaconda' \
        --no-link \
        "$@"
}

koopa::install_autoconf() { # {{{1
    local install_args
    install_args=('--name=autoconf')
    # m4 is required for automake to build.
    if koopa::is_macos
    then
        install_args+=('--homebrew-opt=m4')
    fi
    koopa::install_gnu_app "${install_args[@]}" "$@"
}

koopa::install_automake() { # {{{1
    koopa::install_gnu_app \
        --name='automake' \
        --opt='autoconf' \
        "$@"
}

koopa::install_bash() { # {{{1
    koopa::install_app \
        --name-fancy='Bash' \
        --name='bash' \
        "$@"
}

koopa::install_binutils() { # {{{1
    koopa::install_gnu_app \
        --name='binutils' \
        "$@"
}

koopa::install_chemacs() { # {{{1
    koopa::install_app \
        --name-fancy='Chemacs' \
        --name='chemacs' \
        --version='rolling' \
        "$@"
}

koopa::install_cmake() { # {{{1
    koopa::install_app \
        --name='cmake' \
        --name-fancy='CMake' \
        "$@"
}

koopa::install_conda() { # {{{1
    koopa::install_miniconda "$@"
}

koopa::install_coreutils() { # {{{1
    koopa::install_gnu_app \
        --name='coreutils' \
        "$@"
}

koopa::install_cpufetch() { # {{{1
    koopa::install_app \
        --name='cpufetch' \
        "$@"
}

koopa::install_curl() { # {{{1
    koopa::install_app \
        --name-fancy='cURL' \
        --name='curl' \
        "$@"
}

koopa::install_doom_emacs() { # {{{1
    koopa::install_app \
        --name-fancy='Doom Emacs' \
        --name='doom-emacs' \
        --prefix="$(koopa::doom_emacs_prefix)" \
        --version='rolling' \
        "$@"
}

koopa::install_dotfiles() { # {{{1
    koopa::install_app \
        --name-fancy='Dotfiles' \
        --name='dotfiles' \
        --no-link \
        --version='rolling' \
        "$@"
}

koopa::install_emacs() { # {{{1
    koopa::install_app \
        --name-fancy='Emacs' \
        --name='emacs' \
        "$@"
}

koopa::install_ensembl_perl_api() { # {{{1
    koopa::install_app \
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
    koopa::install_gnu_app \
        --name='findutils' \
        "$@"
}

koopa::install_fish() { # {{{1
    koopa::install_app \
        --name-fancy='Fish' \
        --name='fish' \
        "$@"
}

koopa::install_fzf() { # {{{1
    koopa::install_app \
        --name-fancy='FZF' \
        --name='fzf' \
        "$@"
}

koopa::install_gawk() { # {{{1
    koopa::install_gnu_app \
        --name='gawk' \
        "$@"
}

koopa::install_gcc() { # {{{1
    koopa::install_app \
        --name-fancy='GCC' \
        --name='gcc' \
        --no-link \
        "$@"
}

koopa::install_gdal() { # {{{1
    koopa::install_app \
        --name-fancy='GDAL' \
        --name='gdal' \
        --no-link \
        "$@"
}

koopa::install_geos() { # {{{1
    koopa::install_app \
        --name-fancy='GEOS' \
        --name='geos' \
        --no-link \
        "$@"
}

koopa::install_git() { # {{{1
    koopa::install_app \
        --name-fancy='Git' \
        --name='git' \
        "$@"
}

koopa::install_gnu_app() { # {{{1
    koopa::install_app \
        --installer='gnu-app' \
        "$@"
}

koopa::install_gnupg() { # {{{1
    koopa::install_app \
        --name-fancy='GnuPG suite' \
        --name='gnupg' \
        "$@"
}

koopa::install_go() { # {{{1
    koopa::install_app \
        --name-fancy='Go' \
        --name='go' \
        --no-link \
        "$@"
    koopa::configure_go
    return 0
}

koopa::install_grep() { # {{{1
    koopa::install_gnu_app \
        --name='grep' \
        "$@"
}

koopa::install_groff() { # {{{1
    koopa::install_gnu_app \
        --name='groff' \
        "$@"
}

koopa::install_gsl() { # {{{1
    koopa::install_gnu_app \
        --name='gsl' \
        --name-fancy='GSL' \
        "$@"
}

koopa::install_haskell_stack() { # {{{1
    koopa::install_app \
        --name-fancy='Haskell Stack' \
        --name='haskell-stack' \
        --no-link \
        --version='rolling' \
        "$@"
}

koopa::install_hdf5() { # {{{1
    koopa::install_app \
        --name-fancy='HDF5' \
        --name='hdf5' \
        "$@"
}

koopa::install_homebrew() { # {{{1
    koopa::install_app \
        --name-fancy='Homebrew' \
        --name='homebrew' \
        --system \
        "$@"
}

koopa::install_homebrew_bundle() { # {{{1
    koopa::install_app \
        --name-fancy='Homebrew bundle' \
        --name='homebrew-bundle' \
        --system \
        "$@"
}

koopa::install_htop() { # {{{1
    koopa::install_app \
        --name='htop' \
        "$@"
}

koopa::install_imagemagick() { # {{{1
    koopa::install_app \
        --name-fancy='ImageMagick' \
        --name='imagemagick' \
        "$@"
}

koopa::install_julia() { # {{{1
    if koopa::is_linux
    then
        koopa::install_app \
            --installer="julia-binary" \
            --name-fancy='Julia binary' \
            --name='julia' \
            --platform='linux' \
            "$@"
    else
        koopa::install_app \
            --name-fancy='Julia' \
            --name='julia' \
            "$@"
    fi
    koopa::configure_julia
    return 0
}

koopa::install_julia_packages() { # {{{1
    koopa::install_app_packages \
        --name-fancy='Julia' \
        --name='julia' \
        "$@"
}

koopa::install_lesspipe() { # {{{1
    koopa::install_app \
        --name='lesspipe' \
        "$@"
}

koopa::install_libevent() { # {{{1
    koopa::install_app \
        --name='libevent' \
        "$@"
}

koopa::install_libtool() { # {{{1
    koopa::install_gnu_app \
        --name='libtool' \
        "$@"
}

koopa::install_lua() { # {{{1
    koopa::install_app \
        --name-fancy='Lua' \
        --name='lua' \
        "$@"
}

koopa::install_luarocks() { # {{{1
    koopa::install_app \
        --name='luarocks' \
        "$@"
}

koopa::install_make() { # {{{1
    koopa::install_gnu_app \
        --name='make' \
        "$@"
}

koopa::install_mamba() { # {{{1
    koopa::install_app \
        --name-fancy='Mamba' \
        --name='mamba' \
        --system \
        "$@"
}

koopa::install_miniconda() { # {{{1
    koopa::install_app \
        --installer='miniconda' \
        --name-fancy='Miniconda' \
        --name='conda' \
        --no-link \
        "$@"
}

koopa::install_ncurses() { # {{{1
    koopa::install_gnu_app \
        --name='ncurses' \
        "$@"
}

koopa::install_neofetch() { # {{{1
    koopa::install_app \
        --name='neofetch' \
        "$@"
}

koopa::install_neovim() { # {{{1
    koopa::install_app \
        --name='neovim' \
        "$@"
}

koopa::install_nim() { # {{{1
    koopa::install_app \
        --name='nim' \
        --name-fancy='Nim' \
        --link-include-dirs='bin' \
        "$@"
    koopa::configure_nim
    return 0
}

koopa::install_nim_packages() { # {{{1
    koopa::install_app_packages \
        --name-fancy='Nim' \
        --name='nim' \
        "$@"
}

koopa::install_node_packages() { # {{{1
    koopa::install_app_packages \
        --name-fancy='Node' \
        --name='node' \
        "$@"
}

koopa::install_openjdk() { # {{{1
    koopa::install_app \
        --name-fancy='OpenJDK' \
        --name='openjdk' \
        --no-link \
        "$@"
}

koopa::install_openssh() { # {{{1
    koopa::install_app \
        --name-fancy='OpenSSH' \
        --name='openssh' \
        --no-link \
        "$@"
}

koopa::install_openssl() { # {{{1
    koopa::install_app \
        --name-fancy='OpenSSL' \
        --name='openssl' \
        --no-link \
        "$@"
}

koopa::install_parallel() { # {{{1
    koopa::install_gnu_app \
        --name='parallel' \
        "$@"
}

koopa::install_password_store() { # {{{1
    koopa::install_app \
        --name='password-store' \
        "$@"
}

koopa::install_patch() { # {{{1
    koopa:::install_gnu_app \
        --name='patch' \
        "$@"
}

koopa::install_perl() { # {{{1
    koopa::install_app \
        --name-fancy='Perl' \
        --name='perl' \
        "$@"
    koopa::configure_perl
    return 0
}

koopa::install_perl_packages() { # {{{1
    koopa::install_app_packages \
        --name-fancy='Perl' \
        --name='perl' \
        "$@"
}

koopa::install_perlbrew() { # {{{1
    koopa::install_app \
        --name-fancy='Perlbrew' \
        --name='perlbrew' \
        --no-link \
        --version='rolling' \
        "$@"
}

koopa::install_pkg_config() { # {{{1
    koopa::install_app \
        --name='pkg-config' \
        "$@"
}

koopa::install_prelude_emacs() { # {{{1
    koopa::install_app \
        --name-fancy='Prelude Emacs' \
        --name='prelude-emacs' \
        --prefix="$(koopa::prelude_emacs_prefix)" \
        --version='rolling' \
        "$@"
}

koopa::install_proj() { # {{{1
    koopa::install_app \
        --name-fancy='PROJ' \
        --name='proj' \
        --no-link \
        "$@"
}

koopa::install_pyenv() { # {{{1
    koopa::install_app \
        --name='pyenv' \
        --no-link \
        --version='rolling' \
        "$@"
}

koopa::install_python() { # {{{1
    koopa::install_app \
        --name-fancy='Python' \
        --name='python' \
        "$@"
}

koopa::install_python_packages() { # {{{1
    koopa::install_app_packages \
        --name-fancy='Python' \
        --name='python' \
        "$@"
}

koopa::install_r() { # {{{1
    koopa::install_app \
        --name-fancy='R' \
        --name='r' \
        "$@"
}

koopa::install_r_cmd_check() { # {{{1
    koopa::install_app \
        --name-fancy='R CMD check' \
        --name='r-cmd-check' \
        --no-link \
        --version='rolling' \
        "$@"
}

koopa::install_r_koopa() { # {{{1
    koopa::assert_has_no_args "$#"
    koopa::r_koopa 'header'
    return 0
}

koopa::install_r_packages() { # {{{1
    koopa::install_app_packages \
        --name-fancy='R' \
        --name='r' \
        "$@"
}

koopa::install_rbenv() { # {{{1
    koopa::install_app \
        --name='rbenv' \
        --no-link \
        --version='rolling' \
        "$@"
}

koopa::install_rmate() { # {{{1
    koopa::install_app \
        --name='rmate' \
        "$@"
}

koopa::install_rsync() { # {{{1
    koopa::install_app \
        --name='rsync' \
        "$@"
}

koopa::install_ruby() { # {{{1
    koopa::install_app \
        --name-fancy='Ruby' \
        --name='ruby' \
        "$@"
    koopa::configure_ruby
}

koopa::install_ruby_packages() { # {{{1
    koopa::install_app_packages \
        --name-fancy='Ruby' \
        --name='ruby' \
        "$@"
}

koopa::install_rust() { # {{{1
    koopa::install_app \
        --name-fancy='Rust' \
        --name='rust' \
        --no-link \
        --version='rolling' \
        "$@"
}

koopa::install_rust_packages() { # {{{1
    koopa::install_app_packages \
        --name-fancy='Rust' \
        --name='rust' \
        "$@"
}

koopa::install_sed() { # {{{1
    koopa::install_gnu_app \
        --name='sed' \
        "$@"
}

koopa::install_shellcheck() { # {{{1
    koopa::install_app \
        --name-fancy='ShellCheck' \
        --name='shellcheck' \
        "$@"
}

koopa::install_shunit2() { # {{{1
    koopa::install_app \
        --name-fancy='shUnit2' \
        --name='shunit2' \
        "$@"
}

koopa::install_singularity() { # {{{1
    koopa::install_app \
        --name='singularity' \
        "$@"
}

koopa::install_spacemacs() { # {{{1
    koopa::install_app \
        --name-fancy='Spacemacs' \
        --name='spacemacs' \
        --prefix="$(koopa::spacemacs_prefix)" \
        --version='rolling' \
        "$@"
}

koopa::install_spacevim() { # {{{1
    koopa::install_app \
        --name-fancy='SpaceVim' \
        --name='spacevim' \
        --prefix="$(koopa::spacevim_prefix)" \
        --version='rolling' \
        "$@"
}

koopa::install_sqlite() { # {{{1
    koopa::install_app \
        --name-fancy='SQLite' \
        --name='sqlite' \
        "$@"
}

koopa::install_subversion() { # {{{1
    koopa::install_app \
        --name='subversion' \
        "$@"
}

koopa::install_taglib() { # {{{1
    koopa::install_app \
        --name-fancy='TagLib' \
        --name='taglib' \
        "$@"
}

koopa::install_tar() { # {{{1
    koopa::install_gnu_app \
        --name='tar' \
        "$@"
}

koopa::install_tex_packages() { # {{{1
    koopa::install_app \
        --name-fancy='TeX packages' \
        --name='tex-packages' \
        --system \
        --version='rolling' \
        "$@"
}

koopa::install_texinfo() { # {{{1
    koopa::install_gnu_app \
        --name='texinfo' \
        "$@"
}

koopa::install_the_silver_searcher() { # {{{1
    koopa::install_app \
        --name='the-silver-searcher' \
        "$@"
}

koopa::install_tmux() { # {{{1
    koopa::install_app \
        --name='tmux' \
        "$@"
}

koopa::install_udunits() { # {{{1
    koopa::install_app \
        --name='udunits' \
        "$@"
}

koopa::install_vim() { # {{{1
    koopa::install_app \
        --name-fancy='Vim' \
        --name='vim' \
        "$@"
}

koopa::install_wget() { # {{{1
    koopa::install_app \
        --name='wget' \
        "$@"
}

koopa::install_zsh() { # {{{1
    koopa::install_app \
        --name-fancy='Zsh' \
        --name='zsh' \
        "$@"
    koopa::fix_zsh_permissions
    return 0
}

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
        --prefix="$(koopa::doom_emacs_prefix)" \
        "$@"
}

koopa::uninstall_dotfiles() { # {{{1
    # """
    # Uninstall dotfiles.
    # @note Updated 2022-02-15.
    # """
    local app dict
    koopa::assert_has_no_args "$#"
    declare -A app=(
        [bash]="$(koopa::locate_bash)"
    )
    declare -A dict=(
        [name_fancy]='Dotfiles'
        [name]='dotfiles'
        [prefix]="$(koopa::dotfiles_prefix)"
    )
    dict[script]="${dict[prefix]}/uninstall"
    koopa::assert_is_file "${dict[script]}"
    "${app[bash]}" "${dict[script]}"
    koopa::uninstall_app \
        --name-fancy="${dict[name_fancy]}" \
        --name="${dict[name]}" \
        --prefix="${dict[prefix]}" \
        "$@"
    return 0
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

koopa::uninstall_gnupg() { # {{{1
    local dict
    koopa::assert_has_no_args "$#"
    declare -A dict=(
        [name_fancy]='GnuPG suite'
    )
    koopa::alert_uninstall_start "${dict[name_fancy]}"
    koopa::uninstall_app --name='gnupg'
    koopa::uninstall_app --name='libassuan'
    koopa::uninstall_app --name='libgcrypt'
    koopa::uninstall_app --name='libgpg-error'
    koopa::uninstall_app --name='libksba'
    koopa::uninstall_app --name='npth'
    koopa::alert_uninstall_success "${dict[name_fancy]}"
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

koopa::uninstall_homebrew() { # {{{1
    koopa::uninstall_app \
        --name-fancy='Homebrew' \
        --name='homebrew' \
        --system \
        "$@"
}

koopa::uninstall_htop() { # {{{1
    koopa::uninstall_app \
        --name='htop' \
        "$@"
}

koopa::uninstall_imagemagick() { # {{{1
    koopa::uninstall_app \
        --name-fancy='ImageMagick' \
        --name='imagemagick' \
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
    local app
    declare -A app=(
        [bash]="$(koopa::locate_bash)"
    )
    "${app[bash]}" "$(koopa::koopa_prefix)/uninstall" "$@"
    return 0
}

koopa::uninstall_lesspipe() { # {{{1
    koopa::uninstall_app \
        --name='lesspipe' \
        "$@"
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
    local dict
    declare -A dict
    koopa::uninstall_app \
        --name-fancy='OpenJDK' \
        --name='openjdk' \
        --no-link \
        "$@"
    if koopa::is_linux
    then
        dict[default_java]='/usr/lib/jvm/default-java'
        if [[ -d "${dict[default_java]}" ]]
        then
            koopa::linux_java_update_alternatives "${dict[default_java]}"
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

koopa::uninstall_perlbrew() { # {{{1
    koopa::uninstall_app \
        --name-fancy='Perlbrew' \
        --name='perlbrew' \
        --no-link \
        "$@"
}

koopa::uninstall_pkg_config() { # {{{1
    koopa::uninstall_app \
        --name='pkg-config' \
        "$@"
}

koopa::uninstall_prelude_emacs() { # {{{1
    koopa::uninstall_app \
        --name-fancy='Prelude Emacs' \
        --name='prelude-emacs' \
        --prefix="$(koopa::prelude_emacs_prefix)" \
        "$@"
}

koopa::uninstall_proj() { # {{{1
    koopa::uninstall_app \
        --name-fancy='PROJ' \
        --name='proj' \
        --no-link \
        "$@"
}

koopa::uninstall_pyenv() { # {{{1
    koopa::uninstall_app \
        --name='pyenv' \
        --no-link \
        "$@"
}

koopa::uninstall_python() { # {{{1
    koopa::uninstall_app \
        --name-fancy='Python' \
        --name='python' \
        "$@"
}

koopa::uninstall_python_packages() { # {{{1
    koopa::uninstall_app \
        --name-fancy='Python packages' \
        --name='python-packages' \
        --no-link \
        "$@"
}

koopa::uninstall_r() { # {{{1
    koopa::uninstall_app \
        --name-fancy='R' \
        --name='r' \
        "$@"
}

koopa::uninstall_r_cmd_check() { # {{{1
    koopa::uninstall_app \
        --name='r-cmd-check' \
        --no-link \
        "$@"
}

koopa::uninstall_r_packages() { # {{{1
    koopa::uninstall_app \
        --name-fancy='R packages' \
        --name='r-packages' \
        --no-link \
        "$@"
}

koopa::uninstall_rbenv() { # {{{1
    koopa::uninstall_app \
        --name='rbenv' \
        --no-link \
        "$@"
}

koopa::uninstall_rmate() { # {{{1
    koopa::uninstall_app \
        --name='rmate' \
        "$@"
}

koopa::uninstall_rsync() { # {{{1
    koopa::uninstall_app \
        --name='rsync' \
        "$@"
}

koopa::uninstall_ruby() { # {{{1
    koopa::uninstall_app \
        --name-fancy='Ruby' \
        --name='ruby' \
        "$@"
}

koopa::uninstall_ruby_packages() { # {{{1
    koopa::uninstall_app \
        --name-fancy='Ruby packages' \
        --name='ruby-packages' \
        --no-link \
        "$@"
}

koopa::uninstall_rust() { # {{{1
    koopa::uninstall_app \
        --name-fancy='Rust' \
        --name='rust' \
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

koopa::uninstall_shellcheck() { # {{{1
    koopa::uninstall_app \
        --name-fancy='ShellCheck' \
        --name='shellcheck' \
        "$@"
}

koopa::uninstall_shunit2() { # {{{1
    koopa::uninstall_app \
        --name-fancy='shUnit2' \
        --name='shunit2' \
        "$@"
}

koopa::uninstall_singularity() { # {{{1
    koopa::uninstall_app \
        --name='singularity' \
        "$@"
}

koopa::uninstall_spacemacs() { # {{{1
    koopa::uninstall_app \
        --name-fancy='Spacemacs' \
        --name='spacemacs' \
        --prefix="$(koopa::spacemacs_prefix)" \
        "$@"
}

koopa::uninstall_spacevim() { # {{{1
    koopa::uninstall_app \
        --name-fancy='SpaceVim' \
        --name='spacevim' \
        --prefix="$(koopa::spacevim_prefix)" \
        "$@"
}

koopa::uninstall_sqlite() { # {{{1
    koopa::uninstall_app \
        --name-fancy='SQLite' \
        --name='sqlite' \
        "$@"
}

koopa::uninstall_subversion() { # {{{1
    koopa::uninstall_app \
        --name='subversion' \
        "$@"
}

koopa::uninstall_taglib() { # {{{1
    koopa::uninstall_app \
        --name-fancy='TagLib' \
        --name='taglib' \
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

koopa::uninstall_the_silver_searcher() { # {{{1
    koopa::uninstall_app \
        --name='the-silver-searcher' \
        "$@"
}

koopa::uninstall_tmux() { # {{{1
    koopa::uninstall_app \
        --name='tmux' \
        "$@"
}

koopa::uninstall_udunits() { # {{{1
    koopa::uninstall_app \
        --name='udunits' \
        "$@"
}

koopa::uninstall_vim() { # {{{1
    koopa::uninstall_app \
        --name-fancy='Vim' \
        --name='vim' \
        "$@"
}

koopa::uninstall_wget() { # {{{1
    koopa::uninstall_app \
        --name='wget' \
        "$@"
}

koopa::uninstall_zsh() { # {{{1
    koopa::uninstall_app \
        --name-fancy="Zsh" \
        --name='zsh' \
        "$@"
}

koopa::update_chemacs() { # {{{1
    koopa::update_app \
        --name='chemacs' \
        --name-fancy='Chemacs' \
        "$@"
}

koopa::update_doom_emacs() { # {{{1
    koopa::update_app \
        --name-fancy='Doom Emacs' \
        --name='doom-emacs' \
        --prefix="$(koopa::doom_emacs_prefix)" \
        "$@"
}

koopa::update_dotfiles() { # {{{1
    koopa::update_app \
        --name='dotfiles' \
        --name-fancy='Dotfiles' \
        "$@"
}

koopa::update_homebrew() { # {{{1
    koopa::update_app \
        --name='homebrew' \
        --name-fancy='Homebrew' \
        --system \
        "$@"
}

koopa::update_julia_packages() { # {{{1
    koopa::install_julia_packages "$@"
}

koopa::update_koopa() { # {{{1
    koopa::update_app \
        --name='koopa' \
        --prefix="$(koopa::koopa_prefix)" \
        --system \
        "$@"
}

koopa::update_mamba() { # {{{1
    koopa::install_mamba "$@"
}

koopa::update_nim_packages() { # {{{1
    koopa::install_nim_packages "$@"
}

koopa::update_node_packages() { # {{{1
    koopa::install_node_packages "$@"
}

koopa::update_perl_packages() { # {{{1
    koopa::install_perl_packages "$@"
}

koopa::update_perlbrew() { # {{{1
    koopa::update_app \
        --name='perlbrew' \
        --name-fancy='Perlbrew' \
        "$@"
}

koopa::update_prelude_emacs() { # {{{1
    koopa::update_app \
        --name-fancy='Prelude Emacs' \
        --name='prelude-emacs' \
        --prefix="$(koopa::prelude_emacs_prefix)" \
        "$@"
}

koopa::update_pyenv() { # {{{1
    koopa::update_app \
        --name='pyenv' \
        "$@"
}

koopa::update_r_cmd_check() { # {{{1
    koopa::update_app \
        --name='r-cmd-check' \
        --name-fancy='R CMD check' \
        "$@"
}

koopa::update_r_packages() { # {{{1
    koopa::update_app \
        --name-fancy='R packages' \
        --name='r-packages' \
        "$@"
}

koopa::update_rbenv() { # {{{1
    koopa::update_app \
        --name='rbenv' \
        "$@"
}

koopa::update_ruby_packages() {  # {{{1
    koopa::install_ruby_packages "$@"
}

koopa::update_rust() { # {{{1
    koopa::update_app \
        --name-fancy='Rust' \
        --name='rust' \
        "$@"
}

koopa::update_rust_packages() { # {{{1
    koopa::update_app \
        --name-fancy='Rust packages' \
        --name='rust-packages' \
        "$@"
}

koopa::update_spacemacs() { # {{{1
    koopa::update_app \
        --name-fancy='Spacemacs' \
        --name='spacemacs' \
        --prefix="$(koopa::spacemacs_prefix)" \
        "$@"
}

koopa::update_spacevim() { # {{{1
    koopa::update_app \
        --name-fancy='SpaceVim' \
        --name='spacevim' \
        --prefix="$(koopa::spacevim_prefix)" \
        "$@"
}

koopa::update_system() { # {{{1
    koopa::update_app \
        --name='system' \
        --system \
        "$@"
}

koopa::update_tex_packages() { # {{{1
    koopa::update_app \
        --name-fancy='TeX packages' \
        --name='tex-packages' \
        --system \
        "$@"
}
