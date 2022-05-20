#!/usr/bin/env bash

koopa_debian_uninstall_bcbio_nextgen_vm() {
    koopa_uninstall_app \
        --name='bcbio-nextgen-vm' \
        --platform='debian' \
        "$@"
}
