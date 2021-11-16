#!/usr/bin/env bash

# FIXME Need to improve consolidation of wrappers here.

koopa::linux_install_aspera_connect() { # {{{1
    koopa:::install_app \
        --name='aspera-connect' \
        --name-fancy='Aspera Connect' \
        --no-link \
        --platform='linux' \
        "$@"
}

# FIXME This should only link aws, but not aws_completer.
koopa::linux_install_aws_cli() { # {{{1
    koopa:::install_app \
        --name='aws-cli' \
        --name-fancy='AWS CLI' \
        --link-include='bin/aws' \
        --platform='linux' \
        --version='rolling' \
        "$@"
}

koopa::linux_install_bcbio_nextgen() { # {{{1
    koopa:::install_app \
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
        koopa:::install_app \
            --name='bcl2fastq' \
            --platform='fedora' \
            --installer='bcl2fastq-from-rpm' \
            "$@"
    else
        koopa:::install_app \
            --name='bcl2fastq' \
            --platform='linux' \
            "$@"
    fi
    return 0
}

koopa::linux_install_cellranger() { # {{{1
    koopa:::install_app \
        --name='cellranger' \
        --name-fancy='Cell Ranger' \
        --no-link \
        --platform='linux' \
        "$@"
}

koopa::linux_install_cloudbiolinux() { # {{{1
    koopa:::install_app \
        --name='cloudbiolinux' \
        --name-fancy='CloudBioLinux' \
        --no-link \
        --platform='linux' \
        --version='rolling' \
        "$@"
}

koopa::linux_install_docker_credential_pass() { # {{{1
    koopa:::install_app \
        --name='docker-credential-pass' \
        --platform='linux' \
        "$@"
}

koopa::linux_install_lmod() { # {{{1
    koopa:::install_app \
        --name='lmod' \
        --name-fancy='Lmod' \
        --no-link \
        --platform='linux' \
        "$@"
}

koopa::linux_uninstall_aspera_connect() { # {{{1
    # """
    # Uninstall Aspera Connect.
    # @note Updated 2021-06-11.
    # """
    koopa:::uninstall_app \
        --name='aspera-connect' \
        --name-fancy='Aspera Connect' \
        --no-link \
        "$@"
}

koopa::linux_uninstall_aws_cli() { # {{{1
    # """
    # Uninstall AWS CLI.
    # @note Updated 2021-06-11.
    # """
    koopa:::uninstall_app \
        --name='aws-cli' \
        --name-fancy='AWS CLI' \
        "$@"
}

koopa::linux_uninstall_bcbio_nextgen() { # {{{1
    # """
    # Uninstall bcbio-nextgen.
    # @note Updated 2021-11-16.
    # """
    koopa:::install_app \
        --name='bcbio-nextgen' \
        --no-link \
        "$@"
}

koopa::linux_uninstall_bcl2fastq() { # {{{1
    # """
    # Uninstall bcl2fastq.
    # @note Updated 2021-06-11.
    # """
    koopa:::uninstall_app \
        --name='bcl2fastq' \
        "$@"
}

koopa::linux_uninstall_cellranger() { # {{{1
    # """
    # Uninstall Cell Ranger.
    # @note Updated 2021-06-11.
    # """
    koopa:::uninstall_app \
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
    koopa:::uninstall_app \
        --name='cloudbiolinux' \
        --name-fancy='CloudBioLinux' \
        --no-link \
        "$@"
}

koopa::linux_uninstall_docker_credential_pass() { # {{{1
    # """
    # Uninstall docker-credential-pass.
    # @note Updated 2021-06-11.
    # """
    koopa:::uninstall_app \
        --name='docker-credential-pass' \
        "$@"
}

koopa::linux_uninstall_lmod() { # {{{1
    # """
    # Uninstall Lmod.
    # @note Updated 2021-06-14.
    # """
    koopa:::uninstall_app \
        --name='lmod' \
        --name-fancy='Lmod' \
        --no-link \
        "$@"
    koopa::rm --sudo \
        '/etc/profile.d/z00_lmod.csh' \
        '/etc/profile.d/z00_lmod.sh'
    return 0
}
