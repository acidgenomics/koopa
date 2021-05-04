#!/usr/bin/env bash

koopa::linux_install_bcl2fastq() { # {{{1
    # """
    # Install bcl2fastq.
    # @note Updated 2021-02-15.
    #
    # Using pre-built RPM package on Fedora / RHEL / CentOS.
    # Otherwise, build and install from source.
    # """
    if koopa::is_fedora
    then
        koopa:::fedora_install_bcl2fastq_from_rpm "$@"
    else
        koopa::linux_install_app --name='bcl2fastq' "$@"
    fi
    return 0
}
