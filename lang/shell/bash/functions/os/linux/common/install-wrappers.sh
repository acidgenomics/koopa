#!/usr/bin/env bash

# Shared ================================================================== {{{1

# aspera-connect ---------------------------------------------------------- {{{2

koopa_linux_install_aspera_connect() { # {{{3
    koopa_install_app \
        --link-in-bin='bin/ascp' \
        --name-fancy='Aspera Connect' \
        --name='aspera-connect' \
        --platform='linux' \
        "$@"
}

koopa_linux_uninstall_aspera_connect() { # {{{3
    koopa_uninstall_app \
        --name-fancy='Aspera Connect' \
        --name='aspera-connect' \
        --platform='linux' \
        --unlink-in-bin='ascp' \
        "$@"
}

# aws-cli ----------------------------------------------------------------- {{{2

koopa_linux_install_aws_cli() { # {{{3
    koopa_install_app \
        --link-in-bin='bin/aws' \
        --name-fancy='AWS CLI' \
        --name='aws-cli' \
        --platform='linux' \
        "$@"
}

koopa_linux_uninstall_aws_cli() { # {{{3
    koopa_uninstall_app \
        --name-fancy='AWS CLI' \
        --name='aws-cli' \
        --platform='linux' \
        --unlink-in-bin='aws' \
        "$@"
}

# bcbio-nextgen ----------------------------------------------------------- {{{2

koopa_linux_install_bcbio_nextgen() { # {{{3
    koopa_install_app \
        --link-in-bin='tools/bin/bcbio_nextgen.py' \
        --name='bcbio-nextgen' \
        --platform='linux' \
        --version="$(koopa_current_bcbio_nextgen_version)" \
        "$@"
}

koopa_linux_uninstall_bcbio_nextgen() { # {{{3
    koopa_uninstall_app \
        --name='bcbio-nextgen' \
        --platform='linux' \
        --unlink-in-bin='bcbio_nextgen.py' \
        "$@"
}

# bcl2fastq --------------------------------------------------------------- {{{2

# FIXME Split this out as separate binary function...
koopa_linux_install_bcl2fastq() { # {{{3
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

koopa_linux_uninstall_bcl2fastq() { # {{{3
    koopa_uninstall_app \
        --name='bcl2fastq' \
        --platform='linux' \
        --unlink-in-bin='bcl2fastq' \
        "$@"
}

# cellranger -------------------------------------------------------------- {{{2

koopa_linux_install_cellranger() { # {{{3
    koopa_install_app \
        --link-in-bin='bin/cellranger' \
        --name-fancy='Cell Ranger' \
        --name='cellranger' \
        --platform='linux' \
        "$@"
}

koopa_linux_uninstall_cellranger() { # {{{3
    koopa_uninstall_app \
        --name-fancy='Cell Ranger' \
        --name='cellranger' \
        --platform='linux' \
        --unlink-in-bin='cellranger' \
        "$@"
}

# cloudbiolinux ----------------------------------------------------------- {{{2

koopa_linux_install_cloudbiolinux() { # {{{3
    koopa_install_app \
        --name-fancy='CloudBioLinux' \
        --name='cloudbiolinux' \
        --platform='linux' \
        --version='rolling' \
        "$@"
}

koopa_linux_uninstall_cloudbiolinux() { # {{{3
    koopa_uninstall_app \
        --name-fancy='CloudBioLinux' \
        --name='cloudbiolinux' \
        --platform='linux' \
        "$@"
}

# docker-credential-pass -------------------------------------------------- {{{2

koopa_linux_install_docker_credential_pass() { # {{{3
    koopa_install_app \
        --link-in-bin='bin/docker-credential-pass' \
        --name='docker-credential-pass' \
        --platform='linux' \
        "$@"
}

koopa_linux_uninstall_docker_credential_pass() { # {{{3
    koopa_uninstall_app \
        --name='docker-credential-pass' \
        --platform='linux' \
        --unlink-in-bin='docker-credential-pass' \
        "$@"
}

# julia-binary ------------------------------------------------------------ {{{2

koopa_linux_install_julia_binary() { # {{{3
    koopa_install_app \
        --installer="julia-binary" \
        --link-in-bin='bin/julia' \
        --name-fancy='Julia' \
        --name='julia' \
        --platform='linux' \
        "$@"
}

# lmod -------------------------------------------------------------------- {{{2

koopa_linux_install_lmod() { # {{{3
    koopa_install_app \
        --name-fancy='Lmod' \
        --name='lmod' \
        --platform='linux' \
        "$@"
}

# FIXME Ensure that this cleans up 'etc/profile.d'
koopa_linux_uninstall_lmod() { # {{{3
    koopa_uninstall_app \
        --name-fancy='Lmod' \
        --name='lmod' \
        --platform='linux' \
        "$@"
    return 0
}

# System ================================================================== {{{1

# pihole ------------------------------------------------------------------ {{{2

koopa_linux_install_pihole() { # {{{3
    koopa_update_app \
        --name-fancy='Pi-hole' \
        --name='pihole' \
        --platform='linux' \
        --system \
        "$@"
}

# FIXME Need to include a pihole uninstaller.

# pivpn ------------------------------------------------------------------- {{{2

koopa_linux_install_pivpn() { # {{{3
    koopa_update_app \
        --name-fancy='PiVPN' \
        --name='pivpn' \
        --platform='linux' \
        --system \
        "$@"
}

# FIXME Need to include a pihole uninstaller.
