#!/usr/bin/env bash

koopa::install_autoconf() { # {{{1
    koopa::install_gnu_app \
        --name='autoconf' \
        "$@"
}

koopa::install_automake() { # {{{1
    koopa::install_gnu_app \
        --name='automake' \
        "$@"
}

koopa::install_binutils() { # {{{1
    koopa::install_gnu_app \
        --name='binutils' \
        "$@"
}

koopa::install_coreutils() { # {{{1
    koopa::install_gnu_app \
        --name='coreutils' \
        "$@"
}

koopa::install_findutils() { # {{{1
    koopa::install_gnu_app \
        --name='findutils' \
        "$@"
}

koopa::install_gawk() { # {{{1
    koopa::install_gnu_app \
        --name='gawk' \
        "$@"
}

koopa::install_git() { # {{{1
    koopa::install_app \
        --name='git' \
        --name-fancy='Git' \
        "$@"
}

koopa::install_gnupg() { # {{{1
    koopa::install_app \
        --name='gnupg' \
        --name-fancy='GnuPG suite' \
        "$@"
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
        --name='haskell-stack' \
        --name-fancy='Haskell Stack' \
        "$@"
}

koopa::install_hdf5() { # {{{1
    koopa::install_app \
        --name='hdf5' \
        --name-fancy='HDF5' \
        "$@"
}

koopa::install_htop() { # {{{1
    koopa::install_app \
        --name='htop' \
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

koopa::install_make() { # {{{1
    koopa::install_gnu_app \
        --name='make' \
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

koopa::install_parallel() { # {{{1
    koopa::install_gnu_app \
        --name='parallel' \
        "$@"
}

koopa::install_patch() { # {{{1
    koopa::install_gnu_app \
        --name='patch' \
        "$@"
}

koopa::install_perl() { # {{{1
    koopa::install_app \
        --name='perl' \
        --name-fancy='Perl' \
        "$@"
}

koopa::install_pkg_config() { # {{{1
    koopa::install_app \
        --name='pkg-config' \
        "$@"
}

koopa::install_pyenv() { # {{{1
    koopa::install_app \
        --name='pyenv' \
        "$@"
}

koopa::install_rbenv() { # {{{1
    koopa::install_app \
        --name='rbenv' \
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

koopa::install_sed() { # {{{1
    koopa::install_gnu_app \
        --name='sed' \
        "$@"
}

koopa::install_shellcheck() { # {{{1
    koopa::install_app \
        --name='shellcheck' \
        --name-fancy='ShellCheck' \
        "$@"
}

koopa::install_shunit2() { # {{{1
    koopa::install_app \
        --name='shunit2' \
        --name-fancy='shUnit2' \
        "$@"
}

koopa::install_singularity() { # {{{1
    koopa::install_app \
        --name='singularity' \
        "$@"
}

koopa::install_sqlite() { # {{{1
    koopa::install_app \
        --name='sqlite' \
        --name-fancy='SQLite' \
        "$@"
}

koopa::install_subversion() { # {{{1
    koopa::install_app \
        --name='subversion' \
        "$@"
}

koopa::install_tar() { # {{{1
    koopa::install_gnu_app \
        --name='tar' \
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

koopa::install_wget() { # {{{1
    koopa::install_app \
        --name='wget' \
        "$@"
}

koopa::install_zsh() { # {{{1
    koopa::install_app \
        --name='zsh' \
        --name-fancy='Zsh' \
        "$@"
}
