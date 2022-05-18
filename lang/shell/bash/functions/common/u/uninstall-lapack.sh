#!/usr/bin/env bash

koopa_uninstall_lapack() {
    koopa_uninstall_app \
        --name-fancy='LAPACK' \
        --name='lapack' \
        "$@"
}
