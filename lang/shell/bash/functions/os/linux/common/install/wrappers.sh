#!/usr/bin/env bash

koopa::linux_install_openssh() { # {{{1
    koopa::linux_install_app \
        --name='openssh' \
        --name-fancy='OpenSSH' \
        "$@"
}

koopa::linux_install_openssl() { # {{{1
    koopa::linux_install_app \
        --name='openssl' \
        --name-fancy='OpenSSL' \
        --no-link \
        "$@"
}

koopa::linux_install_password_store() { # {{{1
    koopa::linux_install_app \
        --name='password-store' \
        "$@"
}

koopa::linux_install_proj() { # {{{1
    koopa::linux_install_app \
        --name='proj' \
        --name-fancy='PROJ' \
        "$@"
}

koopa::linux_install_python() { # {{{1
    koopa::linux_install_app \
        --name='python' \
        --name-fancy='Python' \
        "$@"
}

koopa::linux_install_r() { # {{{1
    koopa::linux_install_app \
        --name='r' \
        --name-fancy='R' \
        "$@"
}

# NOTE Consider changing 'name' to 'r-devel' here?
koopa::linux_install_r_devel() { # {{{1
    koopa::linux_install_app \
        --name='r' \
        --name-fancy='R' \
        --version='devel' \
        --script-name='r-devel' \
        "$@"
}

koopa::linux_install_ruby() { # {{{1
    koopa::linux_install_app \
        --name='ruby' \
        --name-fancy='Ruby' \
        "$@"
}

koopa::linux_install_taglib() { # {{{1
    koopa::linux_install_app \
        --name='taglib' \
        --name-fancy='TagLib' \
        "$@"
}

koopa::linux_install_udunits() { # {{{1
    koopa::linux_install_app \
        --name='udunits' \
        "$@"
}

koopa::linux_install_vim() { # {{{1
    koopa::linux_install_app \
        --name='vim' \
        --name-fancy='Vim' \
        "$@"
}
