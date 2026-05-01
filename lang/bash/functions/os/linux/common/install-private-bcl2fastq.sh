#!/usr/bin/env bash

_koopa_linux_install_private_bcl2fastq() {
    _koopa_assert_is_not_arm64
    _koopa_install_app \
        --name='bcl2fastq' \
        --platform='linux' \
        --private \
        "$@"
    _koopa_alert_note "Installation requires agreement to terms of service at: \
'https://support.illumina.com/sequencing/sequencing_software/\
bcl2fastq-conversion-software/downloads.html'."
    return 0
}
