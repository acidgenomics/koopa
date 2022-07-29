#!/usr/bin/env bash

koopa_uninstall_bowtie2() {
    koopa_uninstall_app \
        --name='bowtie2' \
        --unlink-in-bin='bowtie2' \
        "$@"
}
