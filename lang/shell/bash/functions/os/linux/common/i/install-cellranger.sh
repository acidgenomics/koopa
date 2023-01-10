#!/usr/bin/env bash

koopa_linux_install_cellranger() {
    koopa_install_app \
        --name='cellranger' \
        --platform='linux' \
        "$@"
    koopa_alert_note "Installation requires agreement to terms of service at: \
'https://support.10xgenomics.com/single-cell-gene-expression/\
software/downloads/latest'."
    return 0
}
