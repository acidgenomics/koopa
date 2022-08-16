#!/usr/bin/env bash

koopa_install_nextflow() {
    koopa_install_app \
        --link-in-bin='nextflow' \
        --name='nextflow' \
        "$@"
}
