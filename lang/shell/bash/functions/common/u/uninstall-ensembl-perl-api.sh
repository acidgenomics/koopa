#!/usr/bin/env bash

koopa_uninstall_ensembl_perl_api() {
    koopa_uninstall_app \
        --name-fancy='Ensembl Perl API' \
        --name='ensembl-perl-api' \
        "$@"
}
