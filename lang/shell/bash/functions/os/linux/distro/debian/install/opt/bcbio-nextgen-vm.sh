#!/usr/bin/env bash

# FIXME Make this Debian-specific.

koopa::debian_install_bcbio_nextgen_vm() { # {{{1
    koopa::install_app \
        --name='bcbio-nextgen-vm' \
        --no-link \
        --platform='debian' \
        "$@"
}

koopa::debian_uninstall_bcbio_nextgen_vm() { # {{{1
    # """
    # Uninstall bcbio-nextgen-vm.
    # @note Updated 2021-11-02.
    # """
    koopa::uninstall_app \
        --name='bcbio-nextgen-vm' \
        --no-link \
        "$@"
}

koopa:::debian_install_bcbio_nextgen_vm() { # {{{1
    # """
    # Install bcbio-nextgen-vm.
    # @note Updated 2021-11-16.
    #
    # Install pinned bcbio-nextgen v1.2.4:
    # > data_dir="${prefix}/v1.2.4"
    # > image='quay.io/bcbio/bcbio-vc:1.2.4-517bb34'
    #
    # Install latest version of bcbio-nextgen:
    # > data_dir="${prefix}/latest"
    # > image='quay.io/bcbio/bcbio-vc:latest'
    # > "${bin_dir}/bcbio_vm.py" --datadir="$data_dir" saveconfig
    # > "${bin_dir}/bcbio_vm.py" install --tools --image "$image"
    # """
    local app dict
    koopa::assert_is_admin
    declare -A app=(
        [bash]="$(koopa::locate_bash)"
        [gpasswd]="$(koopa::locate_gpasswd)"
        [groupadd]="$(koopa::linux_locate_groupadd)"
        [groups]="$(koopa::locate_groups)"
        [service]="$(koopa::debian_locate_service)"
        [sudo]="$(koopa::locate_sudo)"
        [whoami]="$(koopa::locate_whoami)"
    )
    declare -A dict=(
        [arch]="$(koopa::arch)"
        [groups]="$("${app[groups]}")"
        [prefix]="${INSTALL_PREFIX:?}"
        [version]="${INSTALL_VERSION:?}"
        [whoami]="$("${app[whoami]}")"
    )
    # ARM is not yet supported. Check for Intel x86.
    case "${dict[arch]}" in
        'x86_64')
            ;;
        *)
            koopa::stop "Architecture not supported: '${dict[arch]}'."
            ;;
    esac
    # Install is failing latest version of Miniconda installer, so pin
    # specifically to this legacy version instead.
    dict[script]='Miniconda3-py37_4.9.2-Linux-x86_64.sh'
    dict[url]="https://repo.anaconda.com/miniconda/${dict[script]}"
    koopa::download "${dict[url]}" "${dict[script]}"
    "${app[bash]}" "$script" -b -p "${dict[prefix]}/anaconda"
    app[conda]="${dict[prefix]}/anaconda/bin/conda"
    koopa::assert_is_executable "${app[conda]}"
    "${app[conda]}" install --yes \
        --channel='bioconda' \
        --channel='conda-forge' \
        --override-channels \
        "bcbio-nextgen-vm=${dict[version]}"
    if ! koopa::str_detect_fixed "${dict[groups]}" 'docker'
    then
        "${app[sudo]}" "${app[groupadd]}" 'docker'
        "${app[sudo]}" "${app[service]}" docker restart
        "${app[sudo]}" "${app[gpasswd]}" -a "${dict[whoami]}" 'docker'
        newgrp 'docker'
    fi
    return 0
}
