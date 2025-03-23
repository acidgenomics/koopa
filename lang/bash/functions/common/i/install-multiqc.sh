#!/usr/bin/env bash

koopa_install_multiqc() {
    koopa_install_app \
        --installer='python-package' \
        --name='multiqc' \
        "$@"
}
