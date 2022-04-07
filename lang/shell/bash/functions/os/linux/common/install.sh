#!/usr/bin/env bash

koopa_linux_install_aspera_connect() { # {{{1
    koopa_install_app \
        --link-in-bin='bin/ascp' \
        --name-fancy='Aspera Connect' \
        --name='aspera-connect' \
        --platform='linux' \
        "$@"
}

koopa_linux_install_aws_cli() { # {{{1
    koopa_install_app \
        --link-in-bin='bin/aws' \
        --name-fancy='AWS CLI' \
        --name='aws-cli' \
        --platform='linux' \
        --version='rolling' \
        "$@"
}

koopa_linux_install_bcbio_nextgen() { # {{{1
    koopa_install_app \
        --link-in-bin='tools/bin/bcbio_nextgen.py' \
        --name='bcbio-nextgen' \
        --platform='linux' \
        --version="$(koopa_current_bcbio_nextgen_version)" \
        "$@"
}

# FIXME Split this out as separate binary function...
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

koopa_linux_install_cellranger() { # {{{1
    koopa_install_app \
        --link-in-bin='bin/cellranger' \
        --name-fancy='Cell Ranger' \
        --name='cellranger' \
        --platform='linux' \
        "$@"
}

koopa_linux_install_cloudbiolinux() { # {{{1
    koopa_install_app \
        --name-fancy='CloudBioLinux' \
        --name='cloudbiolinux' \
        --platform='linux' \
        --version='rolling' \
        "$@"
}

koopa_linux_install_docker_credential_pass() { # {{{1
    koopa_install_app \
        --link-in-bin='bin/docker-credential-pass' \
        --name='docker-credential-pass' \
        --platform='linux' \
        "$@"
}

koopa_linux_install_julia_binary() { # {{{1
    koopa_install_app \
        --installer="julia-binary" \
        --link-in-bin='bin/julia' \
        --name-fancy='Julia binary' \
        --name='julia' \
        --platform='linux' \
        "$@"
}

# FIXME Double check the '--system' usage here.
koopa_linux_install_lmod() { # {{{1
    koopa_install_app \
        --name-fancy='Lmod' \
        --name='lmod' \
        --platform='linux' \
        --system \
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

koopa_linux_install_shiny_server_binary() { # {{{1
    koopa_install_app \
        --name-fancy='Shiny Server (binary)' \
        --name='shiny-server-binary' \
        --platform='linux' \
        --system \
        "$@"
}

koopa_linux_uninstall_aspera_connect() { # {{{1
    koopa_uninstall_app \
        --name-fancy='Aspera Connect' \
        --name='aspera-connect' \
        --unlink-in-bin='ascp' \
        "$@"
}

koopa_linux_uninstall_aws_cli() { # {{{1
    koopa_uninstall_app \
        --name-fancy='AWS CLI' \
        --name='aws-cli' \
        --unlink-in-bin='aws' \
        "$@"
}

koopa_linux_uninstall_bcbio_nextgen() { # {{{1
    koopa_uninstall_app \
        --name='bcbio-nextgen' \
        --unlink-in-bin='bcbio_nextgen.py' \
        "$@"
}

koopa_linux_uninstall_bcl2fastq() { # {{{1
    koopa_uninstall_app \
        --name='bcl2fastq' \
        --unlink-in-bin='bcl2fastq' \
        "$@"
}

koopa_linux_uninstall_cellranger() { # {{{1
    koopa_uninstall_app \
        --name='cellranger' \
        --name-fancy='Cell Ranger' \
        --unlink-in-bin='cellranger' \
        "$@"
}

koopa_linux_uninstall_cloudbiolinux() { # {{{1
    koopa_uninstall_app \
        --name-fancy='CloudBioLinux' \
        --name='cloudbiolinux' \
        "$@"
}

koopa_linux_uninstall_docker_credential_pass() { # {{{1
    koopa_uninstall_app \
        --name='docker-credential-pass' \
        --unlink-in-bin='bin/docker-credential-pass' \
        "$@"
}

# FIXME Need a Julia binary uninstaller.
# FIXME Consider reworking here to source an additional uninstall script.
# FIXME Ensure that this cleans up profile.d

koopa_linux_uninstall_lmod() { # {{{1
    koopa_uninstall_app \
        --name-fancy='Lmod' \
        --name='lmod' \
        --system \
        "$@"
    return 0
}
