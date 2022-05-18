#!/usr/bin/env bash

# FIXME Split this out as separate binary function...

koopa_linux_install_bcl2fastq() {
    # """
    # Install bcl2fastq.
    # @note Updated 2021-05-06.
    #
    # Using pre-built RPM package on Fedora / RHEL / CentOS.
    # Otherwise, build and install from source.
    # """
    if koopa_is_fedora
    then
        koopa_install_app \
            --link-in-bin='bin/bcl2fastq' \
            --installer='bcl2fastq-from-rpm' \
            --name='bcl2fastq' \
            --platform='fedora' \
            "$@"
    else
        koopa_install_app \
            --link-in-bin='bin/bcl2fastq' \
            --name='bcl2fastq' \
            --platform='linux' \
            "$@"
    fi
    return 0
}
