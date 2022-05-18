#!/usr/bin/env bash

koopa_uninstall_perl() {
    koopa_uninstall_app \
        --name-fancy='Perl' \
        --name='perl' \
        --unlink-in-bin='perl' \
        "$@"
}
