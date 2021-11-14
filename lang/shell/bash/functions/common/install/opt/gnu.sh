#!/usr/bin/env bash








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

koopa::uninstall_ncurses() { # {{{1
    koopa:::uninstall_app \
        --name='ncurses' \
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

koopa::uninstall_sed() { # {{{1
    koopa:::uninstall_app \
        --name='sed' \
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
