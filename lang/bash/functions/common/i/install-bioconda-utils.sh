#!/usr/bin/env bash

koopa_install_bioconda_utils() {
    koopa_install_app \
        --installer='conda-package' \
        --name='bioconda-utils' \
        "$@"
}
