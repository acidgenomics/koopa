#!/usr/bin/env bash

koopa_install_ncbi_sra_tools() {
    koopa_assert_is_not_aarch64
    koopa_install_app \
        --installer='ncbi-sra-tools-conda' \
        --name='ncbi-sra-tools' \
        "$@"
}
