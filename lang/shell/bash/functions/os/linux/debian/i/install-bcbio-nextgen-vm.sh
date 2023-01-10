#!/usr/bin/env bash

koopa_debian_install_bcbio_nextgen_vm() {
    koopa_install_app \
        --name='bcbio-nextgen-vm' \
        --platform='debian' \
        "$@"
}
