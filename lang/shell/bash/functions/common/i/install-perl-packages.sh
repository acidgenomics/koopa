#!/usr/bin/env bash

koopa_install_perl_packages() {
    koopa_install_app_packages \
        --link-in-bin='bin/ack' \
        --link-in-bin='bin/cpanm' \
        --link-in-bin='bin/rename' \
        --name-fancy='Perl' \
        --name='perl' \
        "$@"
}
