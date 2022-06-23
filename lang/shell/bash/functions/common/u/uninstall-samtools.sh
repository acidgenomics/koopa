#!/usr/bin/env bash

koopa_uninstall_samtools() {
    koopa_uninstall_app \
        --name='samtools' \
        --unlink-in-bin='samtools' \
        "$@"
}
