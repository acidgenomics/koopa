#!/usr/bin/env bash

koopa_install_perl() {
    koopa_install_app \
        --link-in-bin='bin/perl' \
        --name-fancy='Perl' \
        --name='perl' \
        "$@"
}
