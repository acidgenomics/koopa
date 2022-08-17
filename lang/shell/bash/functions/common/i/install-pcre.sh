#!/usr/bin/env bash

koopa_install_pcre() {
    koopa_install_app \
        --link-in-bin='pcre-config' \
        --link-in-bin='pcregrep' \
        --link-in-bin='pcretest' \
        --name='pcre' \
        "$@"
}
