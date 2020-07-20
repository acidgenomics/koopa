#!/usr/bin/env bash

koopa::install_autoconf() { # {{{1
    koopa::install_cellar --name='autoconf' "$@"
    return 0
}

koopa::install_autojump() { # {{{1
    koopa::install_cellar --name='autojump' "$@"
    return 0
}

koopa::install_automake() { # {{{1
    koopa::install_cellar --name='automake' "$@"
    return 0
}

koopa::install_aws_cli() { # {{{1
    koopa::install_cellar \
        --name='aws-cli' \
        --name-fancy='AWS CLI' \
        --version='latest' \
        --include-dirs='bin' \
        "$@"
    return 0
}

koopa::install_bash() { # {{{1
    koopa::install_cellar --name='bash' --name-fancy='Bash' "$@"
    return 0
}

koopa::install_binutils() { # {{{1
    koopa::install_cellar --name='binutils' "$@"
    return 0
}

koopa::install_cmake() { # {{{1
    koopa::install_cellar --name='cmake' --name-fancy='CMake' "$@"
    return 0
}

koopa::install_coreutils() { # {{{1
    koopa::install_cellar --name='coreutils' "$@"
    return 0
}

koopa::install_curl() { # {{{1
    koopa::install_cellar --name='curl' --name-fancy='cURL' "$@"
    return 0
}

koopa::install_docker_credential_pass() { # {{{1
    koopa::install_cellar --name='docker-credential-pass' "$@"
    return 0
}

koopa::install_emacs() { # {{{1
    koopa::install_cellar --name='emacs' --name-fancy='Emacs' "$@"
    return 0
}

koopa::install_findutils() { # {{{1
    koopa::install_cellar --name='findutils' "$@"
    return 0
}

koopa::install_fish() { # {{{1
    koopa::install_cellar --name='fish' --name-fancy='Fish' "$@"
    return 0
}

koopa::install_gawk() { # {{{1
    koopa::install_cellar --name='gawk' --name-fancy='GNU awk' "$@"
    return 0
}

koopa::install_gcc() { # {{{1
    koopa::install_cellar --name='gcc' --name-fancy='GCC' "$@"
    return 0
}

koopa::install_gdal() { # {{{1
    koopa::install_cellar --name='gdal' --name-fancy='GDAL' "$@"
    return 0
}

koopa::install_geos() { # {{{1
    koopa::install_cellar --name='geos' --name-fancy='GEOS'
    return 0
}

koopa::install_git() { # {{{1
    koopa::install_cellar --name='git' --name-fancy='Git' "$@"
    return 0
}

koopa::install_gnupg() { # {{{1
    koopa::install_cellar --name='gnupg' --name-fancy='GnuPG suite' "$@"
    if koopa::is_installed gpg-agent
    then
        gpgconf --kill gpg-agent
    fi
    return 0
}

koopa::install_grep() { # {{{1
    koopa::install_cellar --name='grep' "$@"
    return 0
}

koopa::install_gsl() { # {{{1
    koopa::install_cellar --name='gsl' --name-fancy='GSL' "$@"
    return 0
}

koopa::install_hdf5() { # {{{1
    koopa::install_cellar --name='hdf5' --name-fancy='HDF5' "$@"
    return 0
}

koopa::install_htop() { # {{{1
    koopa::install_cellar --name='htop' "$@"
    return 0
}

koopa::install_julia() { # {{{1
    local install_type pos
    install_type='binary'
    pos=()
    while (("$#"))
    do
        case "$1" in
            --binary)
                install_type='binary'
                shift 1
                ;;
            --source)
                install_type='source'
                shift 1
                ;;
            *)
                pos+=("$1")
                shift 1
                ;;
        esac
    done
    [[ "${#pos[@]}" -gt 0 ]] && set -- "${pos[@]}"
    koopa::install_cellar \
        --name='julia' \
        --name-fancy='Julia' \
        --script-name="julia-${install_type}" \
        "$@"
    return 0
}

koopa::install_libtool() { # {{{1
    koopa::install_cellar --name='libtool' "$@"
    return 0
}

koopa::install_lua() { # {{{1
    koopa::install_cellar --name='lua' --name-fancy='Lua' "$@"
    return 0
}

koopa::install_luarocks() { # {{{1
    koopa::install_cellar --name='luarocks' "$@"
    return 0
}

koopa::install_make() { # {{{1
    koopa::install_cellar --name='make' "$@"
    return 0
}

koopa::install_ncurses() { # {{{1
    koopa::install_cellar --name='ncurses' "$@"
    return 0
}

koopa::install_neofetch() { # {{{1
    koopa::install_cellar --name='neofetch' "$@"
    return 0
}

koopa::install_neovim() { # {{{1
    koopa::install_cellar --name='neovim' "$@"
    return 0
}

koopa::install_openssh() { # {{{1
    koopa::install_cellar --name='openssh' --name-fancy='OpenSSH' "$@"
    return 0
}

koopa::install_openssl() { # {{{1
    koopa::install_cellar \
        --name='openssl' \
        --name-fancy='OpenSSL' \
        --cellar-only \
        "$@"
    return 0
}

koopa::install_parallel() { # {{{1
    koopa::install_cellar --name='parallel' "$@"
    return 0
}

koopa::install_password_store() { # {{{1
    # """
    # https://www.passwordstore.org/
    # https://git.zx2c4.com/password-store/
    # """
    koopa::install_cellar --name='password-store' "$@"
    return 0
}

koopa::install_patch() { # {{{1
    koopa::install_cellar --name='patch' "$@"
    return 0
}

koopa::install_perl() { # {{{1
    koopa::install_cellar --name='perl' --name-fancy='Perl' "$@"
    return 0
}

koopa::install_pkg_config() { # {{{1
    koopa::install_cellar --name='pkg-config' "$@"
    return 0
}

koopa::install_proj() { # {{{1
    koopa::install_cellar --name='proj' --name-fancy='PROJ' "$@"
    return 0
}

koopa::install_pyenv() { # {{{1
    koopa::install_cellar --name='pyenv' "$@"
    return 0
}

koopa::install_python() { # {{{1
    koopa::install_cellar --name='python' --name-fancy='Python' "$@"
    return 0
}

koopa::install_r() { # {{{1
    koopa::install_cellar --name='r' --name-fancy='R' "$@"
    return 0
}

koopa::install_rbenv() { # {{{1
    koopa::install_cellar --name='rbenv' "$@"
    return 0
}

koopa::install_rmate() { # {{{1
    koopa::install_cellar --name='rmate' "$@"
    return 0
}

koopa::install_rsync() { # {{{1
    koopa::install_cellar --name='rsync' "$@"
    return 0
}

koopa::install_ruby() { # {{{1
    koopa::install_cellar --name='ruby' --name-fancy='Ruby'
    return 0
}

koopa::install_sed() { # {{{1
    koopa::install_cellar --name='sed' "$@"
    return 0
}

koopa::install_shellcheck() { # {{{1
    koopa::install_cellar --name='shellcheck' --name-fancy='ShellCheck' "$@"
    return 0
}

koopa::install_shunit2() { # {{{1
    koopa::install_cellar --name='shunit2' --name-fancy='shUnit2' "$@"
    return 0
}

koopa::install_singularity() { # {{{1
    koopa::install_cellar --name='singularity' "$@"
    return 0
}

koopa::install_sqlite() { # {{{1
    koopa::install_cellar --name='sqlite' --name-fancy='SQLite' "$@"
    koopa::note 'Reinstall PROJ and GDAL, if applicable.'
    return 0
}

koopa::install_subversion() { # {{{1
    koopa::install_cellar --name='subversion' "$@"
    return 0
}

koopa::install_texinfo() { # {{{1
    koopa::install_cellar --name='texinfo' "$@"
    return 0
}

koopa::install_the_silver_searcher() { # {{{1
    koopa::install_cellar --name='the-silver-searcher' "$@"
    return 0
}

koopa::install_tmux() { # {{{1
    koopa::install_cellar --name='tmux' "$@"
    return 0
}

koopa::install_udunits() { # {{{1
    koopa::install_cellar --name='udunits' "$@"
    return 0
}

koopa::install_vim() { # {{{1
    koopa::install_cellar --name='vim' --name-fancy='Vim' "$@"
    return 0
}

koopa::install_wget() { # {{{1
    koopa::install_cellar --name='wget' "$@"
    return 0
}

koopa::install_zsh() { # {{{1
    koopa::install_cellar --name='zsh' --name-fancy='Zsh' "$@"
    koopa::fix_zsh_permissions
    return 0
}
