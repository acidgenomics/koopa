#!/usr/bin/env bash

koopa_linux_locate_bcbio_setup_genome() {
    koopa_locate_app \
        --app-name='bcbio-nextgen' \
        --bin-name='bcbio_setup_genome.py' \
        "$@"
}
