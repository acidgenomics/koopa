#!/usr/bin/env bash

koopa_install_bowtie2() {
    koopa_install_app \
        --installer='conda-package' \
        --name='bowtie2' \
        "$@"
}
