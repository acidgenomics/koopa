#!/usr/bin/env bash

koopa_install_nextflow() {
    koopa_install_app \
        --installer='conda-env' \
        --link-in-bin='nextflow' \
        --name='nextflow' \
        "$@"
}
