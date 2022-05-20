#!/usr/bin/env bash

koopa_uninstall_perl_packages() {
    koopa_uninstall_app \
        --name-fancy='Perl packages' \
        --name='perl-packages' \
        --unlink-in-bin='ack' \
        --unlink-in-bin='cpanm' \
        --unlink-in-bin='rename' \
        "$@"
}
