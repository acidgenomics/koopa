#!/usr/bin/env bash

# FIXME Create 'koopa::install_gnu_app' that handles these more consistently.
# Check for anything that calls "--script-name='gnu'".

koopa::install_autoconf() { # {{{1
    koopa::install_app \
        --name='autoconf' \
        --script-name='gnu' \
        "$@"
}

koopa::install_automake() { # {{{1
    koopa::install_app \
        --name='automake' \
        --script-name='gnu' \
        "$@"
}

koopa::install_bash() { # {{{1
    koopa::install_app \
        --name='bash' \
        --name-fancy='Bash' \
        "$@"
}

koopa::install_binutils() { # {{{1
    koopa::install_app \
        --name='binutils' \
        --script-name='gnu' \
        "$@"
}

koopa::install_cmake() { # {{{1
    koopa::install_app \
        --name='cmake' \
        --name-fancy='CMake' \
        "$@"
}

koopa::install_coreutils() { # {{{1
    koopa::install_app \
        --name='coreutils' \
        --script-name='gnu' \
        "$@"
}

koopa::install_cpufetch() { # {{{1
    koopa::install_app \
        --name='cpufetch' \
        "$@"
}

koopa::install_curl() { # {{{1
    koopa::install_app \
        --name='curl' \
        --name-fancy='cURL' \
        "$@"
}

koopa::install_emacs() { # {{{1
    koopa::install_app \
        --name='emacs' \
        --name-fancy='Emacs' \
        "$@"
}

koopa::install_findutils() { # {{{1
    koopa::install_app \
        --name='findutils' \
        --script-name='gnu' \
        "$@"
}

koopa::install_fish() { # {{{1
    koopa::install_app \
        --name='fish' \
        --name-fancy='Fish' \
        "$@"
}

koopa::install_gawk() { # {{{1
    koopa::install_app \
        --name='gawk' \
        --name-fancy='GNU awk' \
        --script-name='gnu' \
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
    koopa::install_app \
        --name='grep' \
        --script-name='gnu' \
        "$@"
}

koopa::install_groff() { # {{{1
    koopa::linux_install_app \
        --name='groff' \
        --name-fancy='GNU roff' \
        --script-name='gnu' \
        "$@"
}

koopa::install_gsl() { # {{{1
    koopa::install_app \
        --name='gsl' \
        --name-fancy='GSL' \
        --script-name='gnu' \
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
    koopa::install_app \
        --name='libtool' \
        --script-name='gnu' \
        "$@"
}

koopa::install_make() { # {{{1
    koopa::install_app \
        --name='make' \
        --script-name='gnu' \
        "$@"
}

koopa::install_ncurses() { # {{{1
    koopa::install_app \
        --name='ncurses' \
        --script-name='gnu' \
        "$@"
}

koopa::install_neofetch() { # {{{1
    koopa::install_app \
        --name='neofetch' \
        "$@"
}

koopa::install_parallel() { # {{{1
    koopa::install_app \
        --name='parallel' \
        --script-name='gnu' \
        "$@"
}

koopa::install_patch() { # {{{1
    koopa::install_app \
        --name='patch' \
        --script-name='gnu' \
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
    koopa::install_app \
        --name='sed' \
        --script-name='gnu' \
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
    koopa::install_app \
        --name='tar' \
        --name-fancy='GNU tar' \
        --script-name='gnu' \
        "$@"
}

koopa::install_texinfo() { # {{{1
    koopa::install_app \
        --name='texinfo' \
        --script-name='gnu' \
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
