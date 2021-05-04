#!/usr/bin/env bash

koopa::install_gnupg() { # {{{1
    koopa::install_app \
        --name='gnupg' \
        --name-fancy='GnuPG suite' \
        "$@"
}

koopa::install_libevent() { # {{{1
    koopa::install_app \
        --name='libevent' \
        "$@"
}

koopa::install_neofetch() { # {{{1
    koopa::install_app \
        --name='neofetch' \
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
