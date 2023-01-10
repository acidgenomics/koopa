#!/usr/bin/env bash

koopa_linux_install_bcl2fastq() {
    koopa_install_app \
        --name='bcl2fastq' \
        --platform='linux' \
        "$@"
    koopa_alert_note "Installation requires agreement to terms of service at: \
'https://support.illumina.com/sequencing/sequencing_software/\
bcl2fastq-conversion-software/downloads.html'."
    return 0
}
