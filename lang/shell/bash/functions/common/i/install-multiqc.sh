#!/usr/bin/env bash

koopa_install_multiqc() {
    koopa_install_app \
        --installer='conda-env' \
        --link-in-bin='multiqc' \
        --name='multiqc' \
        "$@"
}
