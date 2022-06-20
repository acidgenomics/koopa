#!/usr/bin/env bash

koopa_fedora_install_bcl2fastq() {
    # """
    # Install bcl2fastq from binary package.
    # @note Updated 2022-06-20.
    # """
    koopa_install_app \
        --installer='bcl2fastq-from-rpm' \
        --link-in-bin='bin/bcl2fastq' \
        --name='bcl2fastq' \
        --platform='fedora' \
        "$@"
}
