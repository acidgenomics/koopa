#!/usr/bin/env bash

# FIXME Need to unlink from koopa bin.

koopa_debian_uninstall_bcbio_nextgen_vm() {
    koopa_uninstall_app \
        --name='bcbio-nextgen-vm' \
        --platform='debian' \
        "$@"
}
