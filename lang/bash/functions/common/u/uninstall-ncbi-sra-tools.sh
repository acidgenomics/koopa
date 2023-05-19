#!/usr/bin/env bash

koopa_uninstall_ncbi_sra_tools() {
    koopa_uninstall_app \
        --name='ncbi-sra-tools' \
        "$@"
}
