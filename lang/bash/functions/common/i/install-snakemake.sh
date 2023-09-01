#!/usr/bin/env bash

koopa_install_snakemake() {
    koopa_install_app \
        --installer='python-package' \
        --name='snakemake' \
        "$@"
}
