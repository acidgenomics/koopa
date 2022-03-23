#!/usr/bin/env bash

koopa_linux_install_aspera_connect() { # {{{1
    koopa_install_app \
        --name-fancy='Aspera Connect' \
        --name='aspera-connect' \
        --no-link \
        --platform='linux' \
        "$@"
}

koopa_linux_install_aws_cli() { # {{{1
    koopa_install_app \
        --link-include='bin/aws' \
        --name-fancy='AWS CLI' \
        --name='aws-cli' \
        --platform='linux' \
        --version='rolling' \
        "$@"
}

koopa_linux_install_bcbio_nextgen() { # {{{1
    koopa_install_app \
        --name='bcbio-nextgen' \
        --no-link \
        --platform='linux' \
        --version="$(koopa_current_bcbio_nextgen_version)" \
        "$@"
}

koopa_linux_install_bcl2fastq() { # {{{1
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
            --installer='bcl2fastq-from-rpm' \
            --name='bcl2fastq' \
            --platform='fedora' \
            "$@"
    else
        koopa_install_app \
            --name='bcl2fastq' \
            --platform='linux' \
            "$@"
    fi
    return 0
}

koopa_linux_install_cellranger() { # {{{1
    koopa_install_app \
        --link-include='bin/cellranger' \
        --name-fancy='Cell Ranger' \
        --name='cellranger' \
        --platform='linux' \
        "$@"
}

koopa_linux_install_cloudbiolinux() { # {{{1
    koopa_install_app \
        --name-fancy='CloudBioLinux' \
        --name='cloudbiolinux' \
        --no-link \
        --platform='linux' \
        --version='rolling' \
        "$@"
}

koopa_linux_install_docker_credential_pass() { # {{{1
    koopa_install_app \
        --name='docker-credential-pass' \
        --platform='linux' \
        "$@"
}

koopa_linux_install_lmod() { # {{{1
    koopa_install_app \
        --name-fancy='Lmod' \
        --name='lmod' \
        --no-link \
        --platform='linux' \
        "$@"
}

koopa_linux_install_pihole() { # {{{1
    koopa_update_app \
        --name-fancy='Pi-hole' \
        --name='pihole' \
        --platform='linux' \
        --system \
        "$@"
}

koopa_linux_install_pivpn() { # {{{1
    koopa_update_app \
        --name-fancy='PiVPN' \
        --name='pivpn' \
        --platform='linux' \
        --system \
        "$@"
}

koopa_linux_install_shiny_server() { # {{{1
    koopa_install_app \
        --name-fancy='Shiny Server' \
        --name='shiny-server' \
        --platform='linux' \
        --system \
        "$@"
}

koopa_linux_uninstall_aspera_connect() { # {{{1
    # """
    # Uninstall Aspera Connect.
    # @note Updated 2021-06-11.
    # """
    koopa_uninstall_app \
        --name-fancy='Aspera Connect' \
        --name='aspera-connect' \
        --no-link \
        "$@"
}

koopa_linux_uninstall_aws_cli() { # {{{1
    # """
    # Uninstall AWS CLI.
    # @note Updated 2021-06-11.
    # """
    koopa_uninstall_app \
        --name-fancy='AWS CLI' \
        --name='aws-cli' \
        "$@"
}

koopa_linux_uninstall_bcbio_nextgen() { # {{{1
    # """
    # Uninstall bcbio-nextgen.
    # @note Updated 2022-03-22.
    # """
    koopa_uninstall_app \
        --name='bcbio-nextgen' \
        --no-link \
        "$@"
}

koopa_linux_uninstall_bcl2fastq() { # {{{1
    # """
    # Uninstall bcl2fastq.
    # @note Updated 2021-06-11.
    # """
    koopa_uninstall_app \
        --name='bcl2fastq' \
        "$@"
}

koopa_linux_uninstall_cellranger() { # {{{1
    # """
    # Uninstall Cell Ranger.
    # @note Updated 2021-06-11.
    # """
    koopa_uninstall_app \
        --name='cellranger' \
        --name-fancy='Cell Ranger' \
        --no-link \
        "$@"
}

koopa_linux_uninstall_cloudbiolinux() { # {{{1
    # """
    # Uninstall CloudBioLinux.
    # @note Updated 2021-06-11.
    # """
    koopa_uninstall_app \
        --name-fancy='CloudBioLinux' \
        --name='cloudbiolinux' \
        --no-link \
        "$@"
}

koopa_linux_uninstall_docker_credential_pass() { # {{{1
    # """
    # Uninstall docker-credential-pass.
    # @note Updated 2021-06-11.
    # """
    koopa_uninstall_app \
        --name='docker-credential-pass' \
        "$@"
}

koopa_linux_uninstall_lmod() { # {{{1
    # """
    # Uninstall Lmod.
    # @note Updated 2021-06-14.
    # """
    koopa_uninstall_app \
        --name-fancy='Lmod' \
        --name='lmod' \
        --no-link \
        "$@"
    koopa_rm --sudo \
        '/etc/profile.d/z00_lmod.csh' \
        '/etc/profile.d/z00_lmod.sh'
    return 0
}

koopa_linux_update_google_cloud_sdk() { # {{{1
    koopa_update_app \
        --name-fancy='Google Cloud SDK' \
        --name='google-cloud-sdk' \
        --platform='linux' \
        --system \
        "$@"
}
