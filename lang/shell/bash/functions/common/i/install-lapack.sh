#!/usr/bin/env bash

koopa_install_lapack() {
    koopa_install_app \
        --name-fancy='LAPACK' \
        --name='lapack' \
        "$@"
}
