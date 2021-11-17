#!/usr/bin/env bash

# FIXME Need to improve consolidation of wrappers here.

koopa::linux_install_aspera_connect() { # {{{1
    koopa::install_app \
        --name-fancy='Aspera Connect' \
        --name='aspera-connect' \
        --no-link \
        --platform='linux' \
        "$@"
}

koopa::linux_install_aws_cli() { # {{{1
    koopa::install_app \
        --link-include='bin/aws' \
        --name-fancy='AWS CLI' \
        --name='aws-cli' \
        --platform='linux' \
        --version='rolling' \
        "$@"
}

koopa::linux_install_bcbio_nextgen() { # {{{1
    koopa::install_app \
        --name='bcbio-nextgen' \
        --no-link \
        --platform='linux' \
        --version="$(koopa::current_bcbio_nextgen_version)" \
        "$@"
}

koopa::linux_install_bcl2fastq() { # {{{1
    # """
    # Install bcl2fastq.
    # @note Updated 2021-05-06.
    #
    # Using pre-built RPM package on Fedora / RHEL / CentOS.
    # Otherwise, build and install from source.
    # """
    if koopa::is_fedora
    then
        koopa::install_app \
            --installer='bcl2fastq-from-rpm' \
            --name='bcl2fastq' \
            --platform='fedora' \
            "$@"
    else
        koopa::install_app \
            --name='bcl2fastq' \
            --platform='linux' \
            "$@"
    fi
    return 0
}

koopa::linux_install_cellranger() { # {{{1
    koopa::install_app \
        --link-include='bin/cellranger' \
        --name-fancy='Cell Ranger' \
        --name='cellranger' \
        --platform='linux' \
        "$@"
}

koopa::linux_install_cloudbiolinux() { # {{{1
    koopa::install_app \
        --name-fancy='CloudBioLinux' \
        --name='cloudbiolinux' \
        --no-link \
        --platform='linux' \
        --version='rolling' \
        "$@"
}

koopa::linux_install_docker_credential_pass() { # {{{1
    koopa::install_app \
        --name='docker-credential-pass' \
        --platform='linux' \
        "$@"
}

koopa::linux_install_lmod() { # {{{1
    koopa::install_app \
        --name-fancy='Lmod' \
        --name='lmod' \
        --no-link \
        --platform='linux' \
        "$@"
}

koopa::linux_uninstall_aspera_connect() { # {{{1
    # """
    # Uninstall Aspera Connect.
    # @note Updated 2021-06-11.
    # """
    koopa::uninstall_app \
        --name-fancy='Aspera Connect' \
        --name='aspera-connect' \
        --no-link \
        "$@"
}

koopa::linux_uninstall_aws_cli() { # {{{1
    # """
    # Uninstall AWS CLI.
    # @note Updated 2021-06-11.
    # """
    koopa::uninstall_app \
        --name-fancy='AWS CLI' \
        --name='aws-cli' \
        "$@"
}

koopa::linux_uninstall_bcbio_nextgen() { # {{{1
    # """
    # Uninstall bcbio-nextgen.
    # @note Updated 2021-11-16.
    # """
    koopa::install_app \
        --name='bcbio-nextgen' \
        --no-link \
        "$@"
}

koopa::linux_uninstall_bcl2fastq() { # {{{1
    # """
    # Uninstall bcl2fastq.
    # @note Updated 2021-06-11.
    # """
    koopa::uninstall_app \
        --name='bcl2fastq' \
        "$@"
}

koopa::linux_uninstall_cellranger() { # {{{1
    # """
    # Uninstall Cell Ranger.
    # @note Updated 2021-06-11.
    # """
    koopa::uninstall_app \
        --name='cellranger' \
        --name-fancy='Cell Ranger' \
        --no-link \
        "$@"
}

koopa::linux_uninstall_cloudbiolinux() { # {{{1
    # """
    # Uninstall CloudBioLinux.
    # @note Updated 2021-06-11.
    # """
    koopa::uninstall_app \
        --name-fancy='CloudBioLinux' \
        --name='cloudbiolinux' \
        --no-link \
        "$@"
}

koopa::linux_uninstall_docker_credential_pass() { # {{{1
    # """
    # Uninstall docker-credential-pass.
    # @note Updated 2021-06-11.
    # """
    koopa::uninstall_app \
        --name='docker-credential-pass' \
        "$@"
}

koopa::linux_uninstall_lmod() { # {{{1
    # """
    # Uninstall Lmod.
    # @note Updated 2021-06-14.
    # """
    koopa::uninstall_app \
        --name-fancy='Lmod' \
        --name='lmod' \
        --no-link \
        "$@"
    koopa::rm --sudo \
        '/etc/profile.d/z00_lmod.csh' \
        '/etc/profile.d/z00_lmod.sh'
    return 0
}
