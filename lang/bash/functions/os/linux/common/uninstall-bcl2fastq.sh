#!/usr/bin/env bash

_koopa_linux_uninstall_private_bcl2fastq() {
    _koopa_uninstall_app \
        --name='bcl2fastq' \
        --platform='linux' \
        "$@"
}
