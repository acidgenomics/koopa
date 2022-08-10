#!/usr/bin/env bash

koopa_uninstall_hisat2() {
    koopa_uninstall_app \
        --name='hisat2' \
        --unlink-in-bin='hisat2' \
        "$@"
}
