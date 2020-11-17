#!/usr/bin/env bash

koopa::install_cellar_autoconf() { # {{{1
    koopa::install_cellar \
        --name='autoconf' \
        "$@"
}

koopa::install_cellar_automake() { # {{{1
    koopa::install_cellar \
        --name='automake' \
        "$@"
}

koopa::install_cellar_bash() { # {{{1
    koopa::install_cellar \
        --name='bash' \
        --name-fancy='Bash' \
        "$@"
}

koopa::install_cellar_binutils() { # {{{1
    koopa::install_cellar \
        --name='binutils' \
        "$@"
}

koopa::install_cellar_cmake() { # {{{1
    koopa::install_cellar \
        --name='cmake' \
        --name-fancy='CMake' \
        "$@"
}

koopa::install_cellar_coreutils() { # {{{1
    koopa::install_cellar \
        --name='coreutils' \
        "$@"
}

koopa::install_cellar_curl() { # {{{1
    koopa::install_cellar \
        --name='curl' \
        --name-fancy='cURL' \
        "$@"
}

koopa::install_cellar_emacs() { # {{{1
    koopa::install_cellar \
        --name='emacs' \
        --name-fancy='Emacs' \
        "$@"
}

koopa::install_cellar_findutils() { # {{{1
    koopa::install_cellar \
        --name='findutils' \
        "$@"
}

koopa::install_cellar_fish() { # {{{1
    koopa::install_cellar \
        --name='fish' \
        --name-fancy='Fish' \
        "$@"
}

koopa::install_cellar_gawk() { # {{{1
    koopa::install_cellar \
        --name='gawk' \
        --name-fancy='GNU awk' \
        "$@"
}

koopa::install_cellar_git() { # {{{1
    koopa::install_cellar \
        --name='git' \
        --name-fancy='Git' \
        "$@"
}

koopa::install_cellar_gnupg() { # {{{1
    koopa::install_cellar \
        --name='gnupg' \
        --name-fancy='GnuPG suite' \
        "$@"
    koopa::is_installed gpg-agent && gpgconf --kill gpg-agent
    return 0
}

koopa::install_cellar_grep() { # {{{1
    koopa::install_cellar \
        --name='grep' \
        "$@"
}

koopa::install_cellar_gsl() { # {{{1
    koopa::install_cellar \
        --name='gsl' \
        --name-fancy='GSL' \
        "$@"
}

koopa::install_cellar_haskell_stack() { # {{{1
    koopa::install_cellar \
        --name='haskell-stack' \
        --name-fancy='Haskell Stack' \
        "$@"
}

koopa::install_cellar_hdf5() { # {{{1
    koopa::install_cellar \
        --name='hdf5' \
        --name-fancy='HDF5' \
        "$@"
}

koopa::install_cellar_htop() { # {{{1
    koopa::install_cellar \
        --name='htop' \
        "$@"
}

koopa::install_cellar_libevent() { # {{{1
    koopa::install_cellar \
        --name='libevent' \
        "$@"
}

koopa::install_cellar_libtool() { # {{{1
    koopa::install_cellar \
        --name='libtool' \
        "$@"
}

koopa::install_cellar_make() { # {{{1
    koopa::install_cellar \
        --name='make' \
        "$@"
}

koopa::install_cellar_ncurses() { # {{{1
    koopa::install_cellar \
        --name='ncurses' \
        "$@"
}

koopa::install_neofetch() { # {{{1
    koopa::install_cellar \
        --name='neofetch' \
        "$@"
}

koopa::install_cellar_parallel() { # {{{1
    koopa::install_cellar \
        --name='parallel' \
        "$@"
}

koopa::install_cellar_patch() { # {{{1
    koopa::install_cellar \
        --name='patch' \
        "$@"
}

koopa::install_cellar_perl() { # {{{1
    koopa::install_cellar \
        --name='perl' \
        --name-fancy='Perl' \
        "$@"
}

koopa::install_cellar_pkg_config() { # {{{1
    koopa::install_cellar \
        --name='pkg-config' \
        "$@"
}

koopa::install_cellar_pyenv() { # {{{1
    koopa::install_cellar \
        --name='pyenv' \
        "$@"
}

koopa::install_cellar_rbenv() { # {{{1
    koopa::install_cellar \
        --name='rbenv' \
        "$@"
}

koopa::install_cellar_rmate() { # {{{1
    koopa::install_cellar \
        --name='rmate' \
        "$@"
}

koopa::install_cellar_rsync() { # {{{1
    koopa::install_cellar \
        --name='rsync' \
        "$@"
}

koopa::install_cellar_sed() { # {{{1
    koopa::install_cellar \
        --name='sed' \
        "$@"
}

koopa::install_cellar_shellcheck() { # {{{1
    koopa::install_cellar \
        --name='shellcheck' \
        --name-fancy='ShellCheck' \
        "$@"
}

koopa::install_cellar_shunit2() { # {{{1
    koopa::install_cellar \
        --name='shunit2' \
        --name-fancy='shUnit2' \
        "$@"
}

koopa::install_cellar_singularity() { # {{{1
    koopa::install_cellar \
        --name='singularity' \
        "$@"
}

koopa::install_cellar_sqlite() { # {{{1
    koopa::install_cellar \
        --name='sqlite' \
        --name-fancy='SQLite' \
        "$@"
    koopa::note 'Reinstall PROJ and GDAL, if built from source.'
    return 0
}

koopa::install_cellar_subversion() { # {{{1
    koopa::install_cellar \
        --name='subversion' \
        "$@"
}

koopa::install_cellar_texinfo() { # {{{1
    koopa::install_cellar \
        --name='texinfo' \
        "$@"
}

koopa::install_cellar_the_silver_searcher() { # {{{1
    koopa::install_cellar \
        --name='the-silver-searcher' \
        "$@"
}

koopa::install_cellar_tmux() { # {{{1
    koopa::install_cellar \
        --name='tmux' \
        "$@"
}

koopa::install_cellar_wget() { # {{{1
    koopa::install_cellar \
        --name='wget' \
        "$@"
}

koopa::install_cellar_zsh() { # {{{1
    koopa::install_cellar \
        --name='zsh' \
        --name-fancy='Zsh' \
        "$@"
    koopa::fix_zsh_permissions
    return 0
}
