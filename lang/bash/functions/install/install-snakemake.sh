#!/usr/bin/env bash

_koopa_install_snakemake() {
    _koopa_install_app \
        --installer='conda-package' \
        --name='snakemake' \
        "$@"
}
