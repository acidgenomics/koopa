#!/usr/bin/env bash

koopa_install_perlbrew() {
    koopa_install_app \
        --link-in-bin='bin/perlbrew' \
        --name-fancy='Perlbrew' \
        --name='perlbrew' \
        "$@"
}
