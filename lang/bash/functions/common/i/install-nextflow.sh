#!/usr/bin/env bash

koopa_install_nextflow() {
    koopa_install_app \
        --installer='conda-package' \
        --name='nextflow' \
        "$@"
}
