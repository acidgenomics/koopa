#!/usr/bin/env bash

koopa_install_ncbi_sra_tools() {
    if koopa_is_aarch64
    then
        koopa_install_app \
            --installer='ncbi-sra-tools-src' \
            --name='ncbi-sra-tools' \
            "$@"
    else
        koopa_install_app \
            --installer='ncbi-sra-tools-conda' \
            --name='ncbi-sra-tools' \
            "$@"
    fi
}
