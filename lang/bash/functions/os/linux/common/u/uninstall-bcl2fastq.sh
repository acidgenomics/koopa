#!/usr/bin/env bash

koopa_linux_uninstall_private_bcl2fastq() {
    koopa_uninstall_app \
        --name='bcl2fastq' \
        --platform='linux' \
        "$@"
}
