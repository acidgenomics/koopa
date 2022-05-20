#!/usr/bin/env bash

koopa_install_gnupg() {
    koopa_install_app \
        --name-fancy='GnuPG suite' \
        --name='gnupg' \
        "$@"
}
