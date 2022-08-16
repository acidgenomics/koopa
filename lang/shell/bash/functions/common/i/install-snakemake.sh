#!/usr/bin/env bash

koopa_install_snakemake() {
    koopa_install_app \
        --link-in-bin='snakemake' \
        --name='snakemake' \
        "$@"
}
