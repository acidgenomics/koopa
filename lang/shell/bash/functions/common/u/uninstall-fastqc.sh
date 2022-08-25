#!/usr/bin/env bash

koopa_uninstall_fastqc() {
    koopa_uninstall_app \
        --name='fastqc' \
        "$@"
}
