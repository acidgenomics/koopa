#!/usr/bin/env bash

koopa_install_snakemake() {
    koopa_install_app \
        --installer='conda-env' \
        --link-in-bin='bin/snakemake' \
        --name='snakemake' \
        "$@"
}
