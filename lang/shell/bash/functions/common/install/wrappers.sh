#!/usr/bin/env bash

koopa::install_gnupg() { # {{{1
    koopa::install_app \
        --name='gnupg' \
        --name-fancy='GnuPG suite' \
        "$@"
}

