#!/usr/bin/env bash

koopa_linux_install_bcl2fastq() {
    # """
    # Install bcl2fastq from source.
    # @note Updated 2021-06-20.
    # """
    koopa_install_app \
        --name='bcl2fastq' \
        --platform='linux' \
        "$@"
}
