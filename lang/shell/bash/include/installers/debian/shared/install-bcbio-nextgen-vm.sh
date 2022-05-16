#!/usr/bin/env bash

main() {
    # """
    # Install bcbio-nextgen-vm.
    # @note Updated 2022-01-25.
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
    koopa_assert_has_no_args "$#"
    declare -A app=(
        [bash]="$(koopa_locate_bash)"
        [gpasswd]="$(koopa_locate_gpasswd)"
        [groupadd]="$(koopa_linux_locate_groupadd)"
        [groups]="$(koopa_locate_groups)"
        [newgrp]="$(koopa_locate_newgrp)"
        [service]="$(koopa_debian_locate_service)"
        [sudo]="$(koopa_locate_sudo)"
        [whoami]="$(koopa_locate_whoami)"
    )
    declare -A dict=(
        [arch]="$(koopa_arch)"
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
            koopa_stop "Architecture not supported: '${dict[arch]}'."
            ;;
    esac
    # Install is failing latest version of Miniconda installer, so pin
    # specifically to this legacy version instead.
    dict[script]='Miniconda3-py37_4.9.2-Linux-x86_64.sh'
    dict[url]="https://repo.anaconda.com/miniconda/${dict[script]}"
    koopa_download "${dict[url]}" "${dict[script]}"
    "${app[bash]}" "$script" -b -p "${dict[prefix]}/anaconda"
    app[conda]="${dict[prefix]}/anaconda/bin/conda"
    koopa_assert_is_executable "${app[conda]}"
    "${app[conda]}" install --yes \
        --channel='bioconda' \
        --channel='conda-forge' \
        --override-channels \
        "bcbio-nextgen-vm=${dict[version]}"
    if koopa_is_admin
    then
        if ! koopa_str_detect_fixed \
            --string="${dict[groups]}" \
            --pattern='docker'
        then
            "${app[sudo]}" "${app[groupadd]}" 'docker'
            "${app[sudo]}" "${app[service]}" docker restart
            "${app[sudo]}" "${app[gpasswd]}" -a "${dict[whoami]}" 'docker'
            "${app[newgrp]}" 'docker'
        fi

    fi
    return 0
}
