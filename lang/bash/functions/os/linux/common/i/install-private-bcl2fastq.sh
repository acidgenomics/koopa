#!/usr/bin/env bash

koopa_linux_install_private_bcl2fastq() {
    koopa_assert_is_not_aarch64
    koopa_install_app \
        --name='bcl2fastq' \
        --platform='linux' \
        --private \
        "$@"
    koopa_alert_note "Installation requires agreement to terms of service at: \
'https://support.illumina.com/sequencing/sequencing_software/\
bcl2fastq-conversion-software/downloads.html'."
    return 0
}
