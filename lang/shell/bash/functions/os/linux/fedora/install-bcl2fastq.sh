#!/usr/bin/env bash

koopa_fedora_install_bcl2fastq() {
    koopa_install_app \
        --link-in-bin='bcl2fastq' \
        --name='bcl2fastq' \
        --platform='fedora' \
        "$@"
}
