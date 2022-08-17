#!/usr/bin/env bash

koopa_uninstall_pcre() {
    koopa_uninstall_app \
        --unlink-in-bin='pcre-config' \
        --unlink-in-bin='pcregrep' \
        --unlink-in-bin='pcretest' \
        --name='pcre' \
        "$@"
}
