#!/usr/bin/env bash

koopa_uninstall_perlbrew() {
    koopa_uninstall_app \
        --name-fancy='Perlbrew' \
        --name='perlbrew' \
        --unlink-in-bin='perlbrew' \
        "$@"
}
