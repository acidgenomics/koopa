#!/usr/bin/env bash

koopa_uninstall_bedtools() {
    koopa_uninstall_app \
        --name='bedtools' \
        --unlink-in-bin='bedtools' \
        "$@"
}
