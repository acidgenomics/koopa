#!/usr/bin/env bash

koopa_uninstall_ensembl_perl_api() {
    koopa_uninstall_app \
        --name='ensembl-perl-api' \
        "$@"
}
