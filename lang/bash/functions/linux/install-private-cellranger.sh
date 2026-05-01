#!/usr/bin/env bash

_koopa_linux_install_private_cellranger() {
    _koopa_assert_is_not_arm64
    _koopa_install_app \
        --name='cellranger' \
        --platform='linux' \
        --private \
        "$@"
    _koopa_alert_note "Installation requires agreement to terms of service at: \
'https://support.10xgenomics.com/single-cell-gene-expression/\
software/downloads/latest'."
    return 0
}
